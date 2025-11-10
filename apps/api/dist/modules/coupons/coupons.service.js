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
exports.CouponsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const coupon_entity_1 = require("../../entities/coupon.entity");
const badge_entity_1 = require("../../entities/badge.entity");
const coupon_category_entity_1 = require("../../entities/coupon_category.entity");
let CouponsService = class CouponsService {
    constructor(repo, badgeRepo, catRepo) {
        this.repo = repo;
        this.badgeRepo = badgeRepo;
        this.catRepo = catRepo;
    }
    async paginate(q) {
        const qb = this.repo.createQueryBuilder('c')
            .leftJoinAndSelect('c.badges', 'b')
            .leftJoinAndSelect('c.categories', 'k');
        if (q.q)
            qb.andWhere('c.title ILIKE :q OR c.code ILIKE :q', { q: `%${q.q}%` });
        if (q.source)
            qb.andWhere('c.sourceId = :sid', { sid: q.source });
        if (q.cat)
            qb.andWhere('k.id = :cid', { cid: q.cat });
        if (q.badge)
            qb.andWhere('b.key = :bk', { bk: q.badge });
        if (q.active === 'true')
            qb.andWhere('c.isActive = true').andWhere('(c.endAt IS NULL OR c.endAt >= NOW())');
        qb.orderBy('c.priority', 'DESC').addOrderBy('c.createdAt', 'DESC');
        const page = q.page ?? 1, limit = q.limit ?? 20;
        qb.skip((page - 1) * limit).take(limit);
        const [items, total] = await qb.getManyAndCount();
        return { items, meta: { page, limit, total } };
    }
    async get(id) {
        const c = await this.repo.findOne({ where: { id }, relations: ['badges', 'categories'] });
        if (!c)
            throw new common_1.NotFoundException('Coupon not found');
        return c;
    }
    async upsert(dto) {
        const badges = dto.badgeIds?.length ? await this.badgeRepo.findBy({ id: (0, typeorm_2.In)(dto.badgeIds) }) : [];
        const cats = dto.categoryIds?.length ? await this.catRepo.findBy({ id: (0, typeorm_2.In)(dto.categoryIds) }) : [];
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
    async deactivate(id) {
        const c = await this.get(id);
        c.isActive = false;
        await this.repo.save(c);
        return { ok: true };
    }
};
exports.CouponsService = CouponsService;
exports.CouponsService = CouponsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(coupon_entity_1.Coupon)),
    __param(1, (0, typeorm_1.InjectRepository)(badge_entity_1.Badge)),
    __param(2, (0, typeorm_1.InjectRepository)(coupon_category_entity_1.CouponCategory)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], CouponsService);
