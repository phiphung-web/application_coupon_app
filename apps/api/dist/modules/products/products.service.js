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
const product_entity_1 = require("../../entities/product.entity");
const category_entity_1 = require("../../entities/category.entity");
const badge_entity_1 = require("../../entities/badge.entity");
const coupon_entity_1 = require("../../entities/coupon.entity");
const product_coupon_entity_1 = require("../../entities/product_coupon.entity");
const pricing_service_1 = require("../pricing/pricing.service");
let ProductsService = class ProductsService {
    constructor(repo, catRepo, badgeRepo, couponRepo, pcRepo, pricing) {
        this.repo = repo;
        this.catRepo = catRepo;
        this.badgeRepo = badgeRepo;
        this.couponRepo = couponRepo;
        this.pcRepo = pcRepo;
        this.pricing = pricing;
    }
    async paginate(q) {
        var _a, _b;
        const qb = this.repo
            .createQueryBuilder("p")
            .leftJoinAndSelect("p.categories", "c")
            .leftJoinAndSelect("p.badges", "b");
        if (q.q)
            qb.andWhere("p.name ILIKE :q", { q: `%${q.q}%` });
        if (q.source)
            qb.andWhere("p.sourceId = :sid", { sid: q.source });
        if (q.cat)
            qb.andWhere("c.id = :cid", { cid: q.cat });
        if (q.badge)
            qb.andWhere("b.key = :bk", { bk: q.badge });
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
        const page = (_a = q.page) !== null && _a !== void 0 ? _a : 1, limit = (_b = q.limit) !== null && _b !== void 0 ? _b : 20;
        qb.skip((page - 1) * limit).take(limit);
        const [items, total] = await qb.getManyAndCount();
        // attach bestDeal nếu cần
        let result = items;
        if (q.withDeal) {
            result = await Promise.all(items.map(async (p) => {
                var _a, _b;
                const pcs = await this.pcRepo.find({ where: { productId: p.id } });
                const couponIds = pcs.map((x) => x.couponId);
                if (couponIds.length === 0)
                    return Object.assign(Object.assign({}, p), { bestDeal: null, primaryCouponId: null });
                const coupons = await this.couponRepo.find({
                    where: { id: (0, typeorm_2.In)(couponIds), isActive: true },
                });
                const primary = (_b = (_a = pcs.find((x) => x.isPrimary)) === null || _a === void 0 ? void 0 : _a.couponId) !== null && _b !== void 0 ? _b : null;
                const best = this.pricing.bestDealForProduct(p, coupons);
                return Object.assign(Object.assign({}, p), { bestDeal: best, primaryCouponId: primary });
            }));
        }
        return { items: result, meta: { page, limit, total } };
    }
    async findOne(id, withDeal = true) {
        var _a, _b;
        const p = await this.repo.findOne({
            where: { id },
            relations: ["categories", "badges"],
        });
        if (!p)
            throw new common_1.NotFoundException("Product not found");
        if (!withDeal)
            return p;
        const pcs = await this.pcRepo.find({ where: { productId: id } });
        const couponIds = pcs.map((x) => x.couponId);
        const coupons = couponIds.length
            ? await this.couponRepo.find({
                where: { id: (0, typeorm_2.In)(couponIds), isActive: true },
            })
            : [];
        const primary = (_b = (_a = pcs.find((x) => x.isPrimary)) === null || _a === void 0 ? void 0 : _a.couponId) !== null && _b !== void 0 ? _b : null;
        const best = coupons.length
            ? this.pricing.bestDealForProduct(p, coupons)
            : null;
        return Object.assign(Object.assign({}, p), { bestDeal: best, primaryCouponId: primary });
    }
    async create(dto) {
        var _a, _b, _c;
        const cats = await this.catRepo.findBy({ id: (0, typeorm_2.In)(dto.categoryIds) });
        const badges = ((_a = dto.badgeIds) === null || _a === void 0 ? void 0 : _a.length)
            ? await this.badgeRepo.findBy({ id: (0, typeorm_2.In)(dto.badgeIds) })
            : [];
        const p = await this.repo.save(this.repo.create({
            name: dto.name,
            imageUrl: dto.imageUrl,
            priceOriginal: dto.priceOriginal,
            priceCurrent: dto.priceCurrent,
            currency: "USD",
            description: dto.description,
            sourceId: dto.sourceId,
            categories: cats,
            badges,
        }));
        // tạo coupon kèm nếu có
        if (dto.createCoupon) {
            const c = await this.couponRepo.save(this.couponRepo.create({
                id: (_b = dto.createCoupon.id) !== null && _b !== void 0 ? _b : `C_${Date.now()}`,
                title: dto.createCoupon.title,
                code: dto.createCoupon.code,
                discountType: dto.createCoupon.discountType,
                discountValue: dto.createCoupon.discountValue,
                minSpend: dto.createCoupon.minSpend,
                maxDiscount: dto.createCoupon.maxDiscount,
                endAt: dto.createCoupon.endAt
                    ? new Date(dto.createCoupon.endAt)
                    : undefined,
                sourceId: (_c = dto.createCoupon.sourceId) !== null && _c !== void 0 ? _c : dto.sourceId,
                isActive: true,
            }));
            await this.pcRepo.save(this.pcRepo.create({ productId: p.id, couponId: c.id, isPrimary: true }));
        }
        return this.findOne(p.id);
    }
    async update(id, dto) {
        var _a, _b, _c, _d, _e, _f;
        const p = await this.repo.findOne({ where: { id } });
        if (!p)
            throw new common_1.NotFoundException("Product not found");
        if (dto.categoryIds) {
            const cats = await this.catRepo.findBy({ id: (0, typeorm_2.In)(dto.categoryIds) });
            p.categories = cats;
        }
        if (dto.badgeIds) {
            const badges = await this.badgeRepo.findBy({ id: (0, typeorm_2.In)(dto.badgeIds) });
            p.badges = badges;
        }
        Object.assign(p, {
            name: (_a = dto.name) !== null && _a !== void 0 ? _a : p.name,
            imageUrl: (_b = dto.imageUrl) !== null && _b !== void 0 ? _b : p.imageUrl,
            priceOriginal: (_c = dto.priceOriginal) !== null && _c !== void 0 ? _c : p.priceOriginal,
            priceCurrent: (_d = dto.priceCurrent) !== null && _d !== void 0 ? _d : p.priceCurrent,
            description: (_e = dto.description) !== null && _e !== void 0 ? _e : p.description,
            sourceId: (_f = dto.sourceId) !== null && _f !== void 0 ? _f : p.sourceId,
        });
        await this.repo.save(p);
        return this.findOne(id);
    }
    async linkCoupon(productId, dto) {
        const p = await this.repo.findOne({ where: { id: productId } });
        if (!p)
            throw new common_1.NotFoundException("Product not found");
        const c = await this.couponRepo.findOne({ where: { id: dto.couponId } });
        if (!c)
            throw new common_1.NotFoundException("Coupon not found");
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
        else
            pc.isPrimary = !!dto.isPrimary;
        await this.pcRepo.save(pc);
        return { ok: true };
    }
    async unlinkCoupon(productId, couponId) {
        await this.pcRepo.delete({ productId, couponId });
        return { ok: true };
    }
};
exports.ProductsService = ProductsService;
exports.ProductsService = ProductsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(product_entity_1.Product)),
    __param(1, (0, typeorm_1.InjectRepository)(category_entity_1.Category)),
    __param(2, (0, typeorm_1.InjectRepository)(badge_entity_1.Badge)),
    __param(3, (0, typeorm_1.InjectRepository)(coupon_entity_1.Coupon)),
    __param(4, (0, typeorm_1.InjectRepository)(product_coupon_entity_1.ProductCoupon)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        pricing_service_1.PricingService])
], ProductsService);
