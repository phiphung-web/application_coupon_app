import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Coupon } from "../../entities/coupon.entity";
import { UpsertCouponDto } from "./dto";
import { PaginationDto } from "../../common/dtos/pagination.dto";

@Injectable()
export class CouponsService {
  constructor(
    @InjectRepository(Coupon) private readonly repo: Repository<Coupon>
  ) {}

  async paginate(q: PaginationDto & { active?: string }) {
    const qb = this.repo
      .createQueryBuilder("c")
      .leftJoinAndSelect("c.source", "source")
      .leftJoinAndSelect("c.category", "category")
      .leftJoinAndSelect("c.badge", "badge");

    if (q.q)
      qb.andWhere("(c.code ILIKE :q OR c.description ILIKE :q)", {
        q: `%${q.q}%`,
      });
    if (typeof q.source === "number")
      qb.andWhere("c.sourceId = :sid", { sid: q.source });
    if (typeof q.cat === "number")
      qb.andWhere("c.categoryId = :cid", { cid: q.cat });
    if (q.badge)
      qb.andWhere("(badge.slug = :slug OR badge.name ILIKE :slugLike)", {
        slug: q.badge,
        slugLike: `%${q.badge}%`,
      });
    if (q.active === "true") {
      qb.andWhere(
        "(c.startDate IS NULL OR c.startDate <= NOW()) AND (c.endDate IS NULL OR c.endDate >= NOW())"
      );
    }

    qb.orderBy("COALESCE(c.startDate, c.createdAt)", "DESC");

    const page = q.page ?? 1;
    const limit = q.limit ?? 20;
    qb.skip((page - 1) * limit).take(limit);

    const [items, total] = await qb.getManyAndCount();
    return { items, meta: { page, limit, total } };
  }

  async get(id: number) {
    const coupon = await this.repo.findOne({
      where: { id },
      relations: ["source", "category", "badge"],
    });
    if (!coupon) throw new NotFoundException("Coupon not found");
    return coupon;
  }

  async upsert(dto: UpsertCouponDto) {
    let entity: Coupon;
    if (dto.id) {
      const existing = await this.repo.findOne({ where: { id: dto.id } });
      if (!existing) throw new NotFoundException("Coupon not found");
      entity = existing;
    } else {
      entity = this.repo.create();
    }

    Object.assign(entity, {
      code: dto.code,
      description: dto.description,
      imageUrl: dto.imageUrl,
      discountType: dto.discountType,
      discountValue:
        dto.discountValue != null ? String(dto.discountValue) : undefined,
      dealUrl: dto.dealUrl,
      sourceId: dto.sourceId,
      categoryId: dto.categoryId,
      badgeId: dto.badgeId,
      startDate: dto.startDate ? new Date(dto.startDate) : undefined,
      endDate: dto.endDate ? new Date(dto.endDate) : undefined,
    });

    const saved = await this.repo.save(entity);
    return this.get(saved.id);
  }

  async deactivate(id: number) {
    const coupon = await this.get(id);
    coupon.endDate = new Date();
    await this.repo.save(coupon);
    return { ok: true };
  }
}
