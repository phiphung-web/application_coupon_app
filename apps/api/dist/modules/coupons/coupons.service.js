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
let CouponsService = class CouponsService {
    constructor(repo) {
        this.repo = repo;
    }
    async paginate(q) {
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
        if (q.discountType) {
            qb.andWhere("c.discountType = :dtype", { dtype: q.discountType });
        }
        if (q.expiresFrom) {
            qb.andWhere("c.endDate >= :expiresFrom", {
                expiresFrom: new Date(q.expiresFrom),
            });
        }
        if (q.expiresTo) {
            qb.andWhere("c.endDate <= :expiresTo", {
                expiresTo: new Date(q.expiresTo),
            });
        }
        if (q.active === "true") {
            qb.andWhere("(c.startDate IS NULL OR c.startDate <= NOW()) AND (c.endDate IS NULL OR c.endDate >= NOW())");
        }
        switch (q.sort) {
            case "ending":
                qb.orderBy("COALESCE(c.endDate, c.createdAt)", "ASC");
                break;
            case "value":
                qb.orderBy("COALESCE(c.discountValue, 0)", "DESC");
                break;
            case "hot":
                qb
                    .orderBy("CASE WHEN badge.slug = 'hot' THEN 1 ELSE 0 END", "DESC")
                    .addOrderBy("c.updatedAt", "DESC");
                break;
            default:
                qb.orderBy("COALESCE(c.startDate, c.createdAt)", "DESC");
        }
        const page = q.page ?? 1;
        const limit = q.limit ?? 20;
        qb.skip((page - 1) * limit).take(limit);
        const [items, total] = await qb.getManyAndCount();
        return { items, meta: { page, limit, total } };
    }
    async get(id) {
        const coupon = await this.repo.findOne({
            where: { id },
            relations: ["source", "category", "badge"],
        });
        if (!coupon)
            throw new common_1.NotFoundException("Coupon not found");
        return coupon;
    }
    async upsert(dto) {
        let entity;
        if (dto.id) {
            const existing = await this.repo.findOne({ where: { id: dto.id } });
            if (!existing)
                throw new common_1.NotFoundException("Coupon not found");
            entity = existing;
        }
        else {
            entity = this.repo.create();
        }
        Object.assign(entity, {
            code: dto.code,
            description: dto.description,
            imageUrl: dto.imageUrl,
            discountType: dto.discountType,
            discountValue: dto.discountValue != null ? String(dto.discountValue) : undefined,
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
    async deactivate(id) {
        const coupon = await this.get(id);
        coupon.endDate = new Date();
        await this.repo.save(coupon);
        return { ok: true };
    }
};
exports.CouponsService = CouponsService;
exports.CouponsService = CouponsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(coupon_entity_1.Coupon)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], CouponsService);
