import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository, In } from "typeorm";
import { Product } from "../../entities/product.entity";
import { Category } from "../../entities/category.entity";
import { Badge } from "../../entities/badge.entity";
import { Coupon } from "../../entities/coupon.entity";
import { ProductCoupon } from "../../entities/product_coupon.entity";
import { CreateProductDto, LinkCouponDto, UpdateProductDto } from "./dto";
import { PaginationDto } from "../../common/dtos/pagination.dto";
import { PricingService } from "../pricing/pricing.service";

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product) private readonly repo: Repository<Product>,
    @InjectRepository(Category) private readonly catRepo: Repository<Category>,
    @InjectRepository(Badge) private readonly badgeRepo: Repository<Badge>,
    @InjectRepository(Coupon) private readonly couponRepo: Repository<Coupon>,
    @InjectRepository(ProductCoupon)
    private readonly pcRepo: Repository<ProductCoupon>,
    private readonly pricing: PricingService
  ) {}

  async paginate(q: PaginationDto & { withDeal?: boolean }) {
    const qb = this.repo
      .createQueryBuilder("p")
      .leftJoinAndSelect("p.categories", "c")
      .leftJoinAndSelect("p.badges", "b");

    if (q.q) qb.andWhere("p.name ILIKE :q", { q: `%${q.q}%` });
    if (q.source) qb.andWhere("p.sourceId = :sid", { sid: q.source });
    if (q.cat) qb.andWhere("c.id = :cid", { cid: q.cat });
    if (q.badge) qb.andWhere("b.key = :bk", { bk: q.badge });

    // sort
    switch (q.sort) {
      case "price_asc":
        qb.orderBy("COALESCE(p.priceCurrent,p.priceOriginal)", "ASC");
        break;
      case "price_desc":
        qb.orderBy("COALESCE(p.priceCurrent,p.priceOriginal)", "DESC");
        break;
      default:
        qb.orderBy("p.id", "DESC");
    }

    const page = q.page ?? 1,
      limit = q.limit ?? 20;
    qb.skip((page - 1) * limit).take(limit);

    const [items, total] = await qb.getManyAndCount();

    // attach bestDeal nếu cần
    let result = items as any[];
    if (q.withDeal) {
      result = await Promise.all(
        items.map(async (p) => {
          const pcs = await this.pcRepo.find({ where: { productId: p.id } });
          const couponIds = pcs.map((x) => x.couponId);
          if (couponIds.length === 0)
            return { ...p, bestDeal: null, primaryCouponId: null };

          const coupons = await this.couponRepo.find({
            where: { id: In(couponIds), isActive: true },
          });
          const primary = pcs.find((x) => x.isPrimary)?.couponId ?? null;
          const best = this.pricing.bestDealForProduct(p, coupons);
          return { ...p, bestDeal: best, primaryCouponId: primary };
        })
      );
    }

    return { items: result, meta: { page, limit, total } };
  }

  async findOne(id: number, withDeal = true) {
    const p = await this.repo.findOne({
      where: { id },
      relations: ["categories", "badges"],
    });
    if (!p) throw new NotFoundException("Product not found");

    if (!withDeal) return p;

    const pcs = await this.pcRepo.find({ where: { productId: id } });
    const couponIds = pcs.map((x) => x.couponId);
    const coupons = couponIds.length
      ? await this.couponRepo.find({
          where: { id: In(couponIds), isActive: true },
        })
      : [];
    const primary = pcs.find((x) => x.isPrimary)?.couponId ?? null;
    const best = coupons.length
      ? this.pricing.bestDealForProduct(p, coupons)
      : null;

    return { ...p, bestDeal: best, primaryCouponId: primary };
  }

  async create(dto: CreateProductDto) {
    const cats = await this.catRepo.findBy({ id: In(dto.categoryIds) });
    const badges = dto.badgeIds?.length
      ? await this.badgeRepo.findBy({ id: In(dto.badgeIds) })
      : [];
    const p = await this.repo.save(
      this.repo.create({
        name: dto.name,
        imageUrl: dto.imageUrl,
        priceOriginal: dto.priceOriginal,
        priceCurrent: dto.priceCurrent,
        currency: "USD",
        description: dto.description,
        sourceId: dto.sourceId,
        categories: cats,
        badges,
      })
    );

    // tạo coupon kèm nếu có
    if (dto.createCoupon) {
      const c = await this.couponRepo.save(
        this.couponRepo.create({
          id: dto.createCoupon.id ?? `C_${Date.now()}`,
          title: dto.createCoupon.title,
          code: dto.createCoupon.code,
          discountType: dto.createCoupon.discountType,
          discountValue: dto.createCoupon.discountValue,
          minSpend: dto.createCoupon.minSpend,
          maxDiscount: dto.createCoupon.maxDiscount,
          endAt: dto.createCoupon.endAt
            ? new Date(dto.createCoupon.endAt)
            : undefined,
          sourceId: dto.createCoupon.sourceId ?? dto.sourceId,
          isActive: true,
        })
      );
      await this.pcRepo.save(
        this.pcRepo.create({ productId: p.id, couponId: c.id, isPrimary: true })
      );
    }

    return this.findOne(p.id);
  }

  async update(id: number, dto: UpdateProductDto) {
    const p = await this.repo.findOne({ where: { id } });
    if (!p) throw new NotFoundException("Product not found");

    if (dto.categoryIds) {
      const cats = await this.catRepo.findBy({ id: In(dto.categoryIds) });
      (p as any).categories = cats;
    }
    if (dto.badgeIds) {
      const badges = await this.badgeRepo.findBy({ id: In(dto.badgeIds) });
      (p as any).badges = badges;
    }

    Object.assign(p, {
      name: dto.name ?? p.name,
      imageUrl: dto.imageUrl ?? p.imageUrl,
      priceOriginal: dto.priceOriginal ?? p.priceOriginal,
      priceCurrent: dto.priceCurrent ?? p.priceCurrent,
      description: dto.description ?? p.description,
      sourceId: dto.sourceId ?? p.sourceId,
    });

    await this.repo.save(p);
    return this.findOne(id);
  }

  async linkCoupon(productId: number, dto: LinkCouponDto) {
    const p = await this.repo.findOne({ where: { id: productId } });
    if (!p) throw new NotFoundException("Product not found");
    const c = await this.couponRepo.findOne({ where: { id: dto.couponId } });
    if (!c) throw new NotFoundException("Coupon not found");

    if (dto.isPrimary) {
      // clear primary cũ
      const primaries = await this.pcRepo.find({
        where: { productId, isPrimary: true },
      });
      for (const pc of primaries) {
        pc.isPrimary = false;
        await this.pcRepo.save(pc);
      }
    }

    let pc = await this.pcRepo.findOne({
      where: { productId, couponId: dto.couponId },
    });
    if (!pc)
      pc = this.pcRepo.create({
        productId,
        couponId: dto.couponId,
        isPrimary: !!dto.isPrimary,
      });
    else pc.isPrimary = !!dto.isPrimary;

    await this.pcRepo.save(pc);
    return { ok: true };
  }

  async unlinkCoupon(productId: number, couponId: string) {
    await this.pcRepo.delete({ productId, couponId });
    return { ok: true };
  }
}
