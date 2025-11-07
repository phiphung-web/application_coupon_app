import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, FindOptionsWhere } from 'typeorm';
import { Coupon } from '../../entities/coupon.entity';
import { CreateCouponDto, ListCouponDto, UpdateCouponDto } from './dto';

@Injectable()
export class CouponsService {
  constructor(@InjectRepository(Coupon) private repo: Repository<Coupon>) {}

  async list(q: ListCouponDto) {
    const { page=1, pageSize=20, q: keyword, categoryId, sourceId, isActive, sort } = q;
    const where: FindOptionsWhere<Coupon> = {};
    if (categoryId) (where as any).categoryId = categoryId;
    if (sourceId) (where as any).sourceId = sourceId;
    if (isActive !== undefined) (where as any).isActive = isActive;
    if (keyword) (where as any).title = () => `ILIKE '%${keyword}%'`;

    const order: any = {};
    switch (sort) {
      case 'priorityDesc': order.priority = 'DESC'; break;
      case 'endAtAsc': order.expiredAt = 'ASC'; break;
      case 'hot': order.priority = 'DESC'; break;
      case 'new': default: order.createdAt = 'DESC';
    }

    const [items, total] = await this.repo.findAndCount({
      where, order, skip: (page-1)*pageSize, take: pageSize,
    });
    return { items, total, page, pageSize };
  }

  get(id: string) { return this.repo.findOne({ where: { id } }); }
  create(dto: CreateCouponDto) {
    const entity = this.repo.create({
      ...dto,
      expiredAt: dto.expiredAt ? new Date(dto.expiredAt) : undefined,
    });
    return this.repo.save(entity);
  }
  async update(id: string, dto: UpdateCouponDto) {
    await this.repo.update({ id }, { ...dto, expiredAt: dto.expiredAt ? new Date(dto.expiredAt) : undefined });
    return this.get(id);
  }
  async remove(id: string) { await this.repo.delete({ id }); return { ok: true }; }

  async hot(limit = 10) {
    const list = await this.repo.find({
      where: { isActive: true },
      order: { priority: 'DESC', expiredAt: 'ASC' },
      take: limit,
    });
    return list;
  }
}
