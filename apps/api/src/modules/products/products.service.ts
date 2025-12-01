import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { In, Repository } from "typeorm";
import { Item } from "../../entities/item.entity";
import { Coupon } from "../../entities/coupon.entity";
import { ItemCouponLink } from "../../entities/item_coupon_link.entity";
import {
  CreateProductDto,
  LinkCouponDto,
  ProductQueryDto,
  UpdateProductDto,
} from "./dto";
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

  async paginate(q: ProductQueryDto & { withDeal?: boolean }) {
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
    if (q.itemType)
      qb.andWhere("i.itemType = :itemType", { itemType: q.itemType });
    if (typeof q.minPrice === "number")
      qb.andWhere("COALESCE(i.price, 0) >= :minPrice", {
        minPrice: q.minPrice,
      });
    if (typeof q.maxPrice === "number")
      qb.andWhere("COALESCE(i.price, 0) <= :maxPrice", {
        maxPrice: q.maxPrice,
      });
    if (q.hasCoupon === "true") {
      qb.andWhere(
        "EXISTS (SELECT 1 FROM item_coupon_links link WHERE link.item_id = i.id)"
      );
    } else if (q.hasCoupon === "false") {
      qb.andWhere(
        "NOT EXISTS (SELECT 1 FROM item_coupon_links link WHERE link.item_id = i.id)"
      );
    }

    switch (q.sort) {
      case "price_asc":
        qb.orderBy("i.price", "ASC");
        break;
      case "price_desc":
        qb.orderBy("i.price", "DESC");
        break;
      case "popular":
        qb.orderBy("i.viewCount", "DESC").addOrderBy("i.id", "DESC");
        break;
      case "newest":
        qb.orderBy("i.createdAt", "DESC");
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

    const itemIds = items.map((it) => it.id);
    const links = itemIds.length
      ? await this.linkRepo.find({ where: { itemId: In(itemIds) } })
      : [];
    const byItem = new Map<number, number>();
    const couponIds = new Set<number>();
    for (const link of links) {
      if (!byItem.has(link.itemId)) {
        byItem.set(link.itemId, link.couponId);
        couponIds.add(link.couponId);
      }
    }
    const coupons = couponIds.size
      ? await this.couponRepo.findBy({ id: In([...couponIds]) })
      : [];
    const couponMap = new Map<number, Coupon>();
    coupons.forEach((c) => couponMap.set(c.id, c));

    const enriched = items.map((item) => {
      const couponId = byItem.get(item.id);
      if (!couponId) {
        return { ...item, bestDeal: null, primaryCouponId: null };
      }
      const coupon = couponMap.get(couponId);
      if (!coupon) {
        return { ...item, bestDeal: null, primaryCouponId: null };
      }
      const best = this.pricing.bestDealForProduct(item, [coupon]);
      return { ...item, bestDeal: best, primaryCouponId: coupon.id };
    });

    return { items: enriched, meta: { page, limit, total } };
  }

  async findOne(id: number, withDeal = true) {
    const item = await this.repo.findOne({
      where: { id },
      relations: ["category", "badge", "source"],
    });
    if (!item) throw new NotFoundException("Item not found");
    this.repo.increment({ id }, "viewCount", 1).catch(() => undefined);

    if (!withDeal) return item;

    const link = await this.linkRepo.findOne({ where: { itemId: id } });
    if (!link) {
      return { ...item, bestDeal: null, primaryCouponId: null };
    }
    const coupon = await this.couponRepo.findOne({
      where: { id: link.couponId },
    });
    if (!coupon) {
      return { ...item, bestDeal: null, primaryCouponId: null };
    }
    const best = this.pricing.bestDealForProduct(item, [coupon]);
    return { ...item, bestDeal: best, primaryCouponId: coupon.id };
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

    await this.linkRepo.delete({ itemId });
    await this.linkRepo.save(
      this.linkRepo.create({
        itemId,
        couponId: dto.couponId,
        isPrimaryDisplay: true,
      })
    );
    return { ok: true };
  }

  async unlinkCoupon(itemId: number, couponId: number) {
    await this.linkRepo.delete({ itemId, couponId });
    return { ok: true };
  }
}
