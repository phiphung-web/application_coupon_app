import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In, MoreThanOrEqual } from 'typeorm';
import { Coupon } from '../../entities/coupon.entity';
import { Badge } from '../../entities/badge.entity';
import { CouponCategory } from '../../entities/coupon_category.entity';
import { UpsertCouponDto } from './dto';
import { PaginationDto } from '../../common/dtos/pagination.dto';

@Injectable()
export class CouponsService {
  constructor(
    @InjectRepository(Coupon) private readonly repo: Repository<Coupon>,
    @InjectRepository(Badge) private readonly badgeRepo: Repository<Badge>,
    @InjectRepository(CouponCategory) private readonly catRepo: Repository<CouponCategory>,
  ) {}

  async paginate(q: PaginationDto & { active?: string }) {
    const qb = this.repo.createQueryBuilder('c')
      .leftJoinAndSelect('c.badges', 'b')
      .leftJoinAndSelect('c.categories', 'k');

    if (q.q) qb.andWhere('c.title ILIKE :q OR c.code ILIKE :q', { q: `%${q.q}%` });
    if (q.source) qb.andWhere('c.sourceId = :sid', { sid: q.source });
    if (q.cat) qb.andWhere('k.id = :cid', { cid: q.cat });
    if (q.badge) qb.andWhere('b.key = :bk', { bk: q.badge });
    if (q.active === 'true') qb.andWhere('c.isActive = true').andWhere('(c.endAt IS NULL OR c.endAt >= NOW())');

    qb.orderBy('c.priority', 'DESC').addOrderBy('c.createdAt', 'DESC');

    const page = q.page ?? 1, limit = q.limit ?? 20;
    qb.skip((page - 1) * limit).take(limit);

    const [items, total] = await qb.getManyAndCount();
    return { items, meta: { page, limit, total } };
  }

  async get(id: string) {
    const c = await this.repo.findOne({ where: { id }, relations: ['badges','categories'] });
    if (!c) throw new NotFoundException('Coupon not found');
    return c;
  }

  async upsert(dto: UpsertCouponDto) {
    const badges = dto.badgeIds?.length ? await this.badgeRepo.findBy({ id: In(dto.badgeIds) }) : [];
    const cats = dto.categoryIds?.length ? await this.catRepo.findBy({ id: In(dto.categoryIds) }) : [];

    const entity = this.repo.create({
      id: dto.id ?? `C_${Date.now()}`,
      title: dto.title, code: dto.code,
      discountType: dto.discountType, discountValue: dto.discountValue,
      minSpend: dto.minSpend, maxDiscount: dto.maxDiscount,
      endAt: dto.endAt ? new Date(dto.endAt) : undefined,
      sourceId: dto.sourceId, imageUrl: dto.imageUrl,
      priority: dto.priority, trackingLink: dto.trackingLink, deeplink: dto.deeplink,
      isActive: dto.isActive ?? true,
      badges, categories: cats,
    });
    await this.repo.save(entity);
    return this.get(entity.id);
  }

  async deactivate(id: string) {
    const c = await this.get(id);
    c.isActive = false;
    await this.repo.save(c);
    return { ok: true };
  }
}
