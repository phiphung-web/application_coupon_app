import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ILike, MoreThan, Repository } from 'typeorm';
import { Coupon } from '../../entities/coupon.entity';
import { CreateCouponDto, QueryCouponsDto, UpdateCouponDto } from './dto';

@Injectable()
export class CouponsService {
  constructor(@InjectRepository(Coupon) private repo: Repository<Coupon>) {}

  create(dto: CreateCouponDto) {
    const c = this.repo.create({
      ...dto,
      applicableTypes: dto.applicableTypes ?? [],
      tags: dto.tags ?? [],
      expiredAt: dto.expiredAt ? new Date(dto.expiredAt) : undefined,
    });
    return this.repo.save(c);
  }

  async update(id: string, dto: UpdateCouponDto) {
    const patch: any = { ...dto };
    if (dto.expiredAt) patch.expiredAt = new Date(dto.expiredAt);
    await this.repo.update({ id }, patch);
    return this.repo.findOneBy({ id });
  }

  async remove(id: string) { await this.repo.delete({ id }); return { ok: true }; }
  getById(id: string) { return this.repo.findOne({ where: { id } }); }

  async hot(limit = 20) {
    return this.repo.find({
      where: [{ tags: ILike('%hot%') }, { priority: MoreThan(79) }],
      order: { priority: 'DESC', id: 'DESC' },
      take: limit,
    });
  }

  async list(q: QueryCouponsDto) {
    const { page = 1, pageSize = 20, categoryId, q: text, sort, shopId } = q;
    const where: any = { isActive: true };
    if (categoryId) where.categoryId = categoryId;
    if (shopId) where.shopId = shopId;
    if (text) where.title = ILike(`%${text}%`);

    const order: any = {};
    switch (sort) {
      case 'priorityDesc': order.priority = 'DESC'; break;
      case 'endAtAsc': order.expiredAt = 'ASC'; break;
      case 'hot': order.priority = 'DESC'; break;
      default: order.id = 'DESC';
    }

    const [data, total] = await this.repo.findAndCount({
      where, order, take: pageSize, skip: (page - 1) * pageSize,
    });
    return { data, total, page, pageSize, hasMore: page * pageSize < total };
  }
}
