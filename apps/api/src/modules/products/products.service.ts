import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { In, Repository } from "typeorm";
import { Item } from "../../entities/item.entity";
import { Coupon } from "../../entities/coupon.entity";
import { ItemCouponLink } from "../../entities/item_coupon_link.entity";
import { CreateProductDto, LinkCouponDto, UpdateProductDto } from "./dto";
import { PaginationDto } from "../../common/dtos/pagination.dto";
import { PricingService } from "../pricing/pricing.service";

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Item) private readonly repo: Repository<Item>,
    @InjectRepository(Coupon) private readonly couponRepo: Repository<Coupon>,
    @InjectRepository(ItemCouponLink)
    private readonly linkRepo: Repository<ItemCouponLink>,
    private readonly pricing: PricingService
  ) {}

  async paginate(q: PaginationDto & { withDeal?: boolean }) {
    const qb = this.repo
      .createQueryBuilder("i")
      .leftJoinAndSelect("i.category", "category")
      .leftJoinAndSelect("i.badge", "badge")
      .leftJoinAndSelect("i.source", "source");

    if (q.q) qb.andWhere("i.name ILIKE :q", { q: `%${q.q}%` });
    if (typeof q.source === "number")
      qb.andWhere("i.sourceId = :sid", { sid: q.source });
    if (typeof q.cat === "number")
      qb.andWhere("i.categoryId = :cid", { cid: q.cat });
    if (q.badge)
      qb.andWhere("(badge.slug = :slug OR badge.name ILIKE :slugLike)", {
        slug: q.badge,
        slugLike: `%${q.badge}%`,
      });

    switch (q.sort) {
      case "price_asc":
        qb.orderBy("i.price", "ASC");
        break;
      case "price_desc":
        qb.orderBy("i.price", "DESC");
        break;
      default:
        qb.orderBy("i.id", "DESC");
    }

    const page = q.page ?? 1;
    const limit = q.limit ?? 20;
    qb.skip((page - 1) * limit).take(limit);

    const [items, total] = await qb.getManyAndCount();
    if (!q.withDeal) {
      return { items, meta: { page, limit, total } };
    }

    const enriched = await Promise.all(
      items.map(async (item) => {
        const links = await this.linkRepo.find({ where: { itemId: item.id } });
        if (!links.length) {
          return { ...item, bestDeal: null, primaryCouponId: null };
        }
        const ids = links.map((l) => l.couponId);
        const coupons = ids.length
          ? await this.couponRepo.findBy({ id: In(ids) })
          : [];
        const primary =
          links.find((l) => l.isPrimaryDisplay)?.couponId ?? null;
        const best = this.pricing.bestDealForProduct(item, coupons);
        return { ...item, bestDeal: best, primaryCouponId: primary };
      })
    );

    return { items: enriched, meta: { page, limit, total } };
  }

  async findOne(id: number, withDeal = true) {
    const item = await this.repo.findOne({
      where: { id },
      relations: ["category", "badge", "source"],
    });
    if (!item) throw new NotFoundException("Item not found");

    if (!withDeal) return item;

    const links = await this.linkRepo.find({ where: { itemId: id } });
    if (!links.length) {
      return { ...item, bestDeal: null, primaryCouponId: null };
    }
    const ids = links.map((l) => l.couponId);
    const coupons = ids.length
      ? await this.couponRepo.findBy({ id: In(ids) })
      : [];
    const primary = links.find((l) => l.isPrimaryDisplay)?.couponId ?? null;
    const best = coupons.length
      ? this.pricing.bestDealForProduct(item, coupons)
      : null;

    return { ...item, bestDeal: best, primaryCouponId: primary };
  }

  async create(dto: CreateProductDto) {
    const entity = this.repo.create({
      name: dto.name,
      description: dto.description,
      imageUrl: dto.imageUrl,
      itemType: dto.itemType,
      itemUrl: dto.itemUrl,
      price: dto.price != null ? String(dto.price) : undefined,
      sourceId: dto.sourceId,
      categoryId: dto.categoryId,
      badgeId: dto.badgeId,
    });
    const saved: Item = await this.repo.save(entity);

    if (dto.createCoupon) {
      const couponEntity = this.couponRepo.create({
        code: dto.createCoupon.code,
        description: dto.createCoupon.description,
        imageUrl: dto.createCoupon.imageUrl,
        discountType: dto.createCoupon.discountType,
        discountValue:
          dto.createCoupon.discountValue != null
            ? String(dto.createCoupon.discountValue)
            : undefined,
        dealUrl: dto.createCoupon.dealUrl,
        sourceId: dto.sourceId,
        categoryId: dto.createCoupon.categoryId ?? dto.categoryId,
        badgeId: dto.createCoupon.badgeId ?? dto.badgeId,
        startDate: dto.createCoupon.startDate
          ? new Date(dto.createCoupon.startDate)
          : undefined,
        endDate: dto.createCoupon.endDate
          ? new Date(dto.createCoupon.endDate)
          : undefined,
      });
      const coupon: Coupon = await this.couponRepo.save(couponEntity);
      await this.linkRepo.save(
        this.linkRepo.create({
          itemId: saved.id,
          couponId: coupon.id,
          isPrimaryDisplay: true,
        })
      );
    }

    return this.findOne(saved.id);
  }

  async update(id: number, dto: UpdateProductDto) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException("Item not found");

    Object.assign(item, {
      name: dto.name ?? item.name,
      description: dto.description ?? item.description,
      imageUrl: dto.imageUrl ?? item.imageUrl,
      itemType: dto.itemType ?? item.itemType,
      itemUrl: dto.itemUrl ?? item.itemUrl,
      price: dto.price != null ? String(dto.price) : item.price,
      sourceId: dto.sourceId ?? item.sourceId,
      categoryId: dto.categoryId ?? item.categoryId,
      badgeId: dto.badgeId ?? item.badgeId,
    });

    await this.repo.save(item);
    return this.findOne(id);
  }

  async linkCoupon(itemId: number, dto: LinkCouponDto) {
    const item = await this.repo.findOne({ where: { id: itemId } });
    if (!item) throw new NotFoundException("Item not found");

    const coupon = await this.couponRepo.findOne({
      where: { id: dto.couponId },
    });
    if (!coupon) throw new NotFoundException("Coupon not found");

    if (dto.isPrimary) {
      const primaries = await this.linkRepo.find({
        where: { itemId, isPrimaryDisplay: true },
      });
      for (const link of primaries) {
        link.isPrimaryDisplay = false;
        await this.linkRepo.save(link);
      }
    }

    let link = await this.linkRepo.findOne({
      where: { itemId, couponId: dto.couponId },
    });
    if (!link) {
      link = this.linkRepo.create({
        itemId,
        couponId: dto.couponId,
        isPrimaryDisplay: dto.isPrimary,
      });
    } else {
      link.isPrimaryDisplay = dto.isPrimary;
    }

    await this.linkRepo.save(link);
    return { ok: true };
  }

  async unlinkCoupon(itemId: number, couponId: number) {
    await this.linkRepo.delete({ itemId, couponId });
    return { ok: true };
  }
}
