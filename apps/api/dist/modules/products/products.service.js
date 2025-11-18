"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProductsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const item_entity_1 = require("../../entities/item.entity");
const coupon_entity_1 = require("../../entities/coupon.entity");
const item_coupon_link_entity_1 = require("../../entities/item_coupon_link.entity");
const pricing_service_1 = require("../pricing/pricing.service");
let ProductsService = class ProductsService {
    constructor(repo, couponRepo, linkRepo, pricing) {
        this.repo = repo;
        this.couponRepo = couponRepo;
        this.linkRepo = linkRepo;
        this.pricing = pricing;
    }
    async paginate(q) {
        const qb = this.repo
            .createQueryBuilder("i")
            .leftJoinAndSelect("i.category", "category")
            .leftJoinAndSelect("i.badge", "badge")
            .leftJoinAndSelect("i.source", "source");
        if (q.q)
            qb.andWhere("i.name ILIKE :q", { q: `%${q.q}%` });
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
        const enriched = await Promise.all(items.map(async (item) => {
            const links = await this.linkRepo.find({ where: { itemId: item.id } });
            if (!links.length) {
                return { ...item, bestDeal: null, primaryCouponId: null };
            }
            const ids = links.map((l) => l.couponId);
            const coupons = ids.length
                ? await this.couponRepo.findBy({ id: (0, typeorm_2.In)(ids) })
                : [];
            const primary = links.find((l) => l.isPrimaryDisplay)?.couponId ?? null;
            const best = this.pricing.bestDealForProduct(item, coupons);
            return { ...item, bestDeal: best, primaryCouponId: primary };
        }));
        return { items: enriched, meta: { page, limit, total } };
    }
    async findOne(id, withDeal = true) {
        const item = await this.repo.findOne({
            where: { id },
            relations: ["category", "badge", "source"],
        });
        if (!item)
            throw new common_1.NotFoundException("Item not found");
        if (!withDeal)
            return item;
        const links = await this.linkRepo.find({ where: { itemId: id } });
        if (!links.length) {
            return { ...item, bestDeal: null, primaryCouponId: null };
        }
        const ids = links.map((l) => l.couponId);
        const coupons = ids.length
            ? await this.couponRepo.findBy({ id: (0, typeorm_2.In)(ids) })
            : [];
        const primary = links.find((l) => l.isPrimaryDisplay)?.couponId ?? null;
        const best = coupons.length
            ? this.pricing.bestDealForProduct(item, coupons)
            : null;
        return { ...item, bestDeal: best, primaryCouponId: primary };
    }
    async create(dto) {
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
        const saved = await this.repo.save(entity);
        if (dto.createCoupon) {
            const couponEntity = this.couponRepo.create({
                code: dto.createCoupon.code,
                description: dto.createCoupon.description,
                imageUrl: dto.createCoupon.imageUrl,
                discountType: dto.createCoupon.discountType,
                discountValue: dto.createCoupon.discountValue != null
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
            const coupon = await this.couponRepo.save(couponEntity);
            await this.linkRepo.save(this.linkRepo.create({
                itemId: saved.id,
                couponId: coupon.id,
                isPrimaryDisplay: true,
            }));
        }
        return this.findOne(saved.id);
    }
    async update(id, dto) {
        const item = await this.repo.findOne({ where: { id } });
        if (!item)
            throw new common_1.NotFoundException("Item not found");
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
    async linkCoupon(itemId, dto) {
        const item = await this.repo.findOne({ where: { id: itemId } });
        if (!item)
            throw new common_1.NotFoundException("Item not found");
        const coupon = await this.couponRepo.findOne({
            where: { id: dto.couponId },
        });
        if (!coupon)
            throw new common_1.NotFoundException("Coupon not found");
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
        }
        else {
            link.isPrimaryDisplay = dto.isPrimary;
        }
        await this.linkRepo.save(link);
        return { ok: true };
    }
    async unlinkCoupon(itemId, couponId) {
        await this.linkRepo.delete({ itemId, couponId });
        return { ok: true };
    }
};
exports.ProductsService = ProductsService;
exports.ProductsService = ProductsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(item_entity_1.Item)),
    __param(1, (0, typeorm_1.InjectRepository)(coupon_entity_1.Coupon)),
    __param(2, (0, typeorm_1.InjectRepository)(item_coupon_link_entity_1.ItemCouponLink)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        pricing_service_1.PricingService])
], ProductsService);
