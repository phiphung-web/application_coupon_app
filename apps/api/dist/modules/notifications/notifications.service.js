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
exports.NotificationsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const notification_entity_1 = require("../../entities/notification.entity");
let NotificationsService = class NotificationsService {
    constructor(repo) {
        this.repo = repo;
    }
    async paginate(q) {
        const qb = this.repo.createQueryBuilder("n");
        if (q.category) {
            qb.andWhere("n.category = :category", { category: q.category });
        }
        if (q.sourceId) {
            qb.andWhere("n.sourceId = :sourceId", { sourceId: q.sourceId });
        }
        if (q.itemId) {
            qb.andWhere("n.itemId = :itemId", { itemId: q.itemId });
        }
        if (q.couponId) {
            qb.andWhere("n.couponId = :couponId", { couponId: q.couponId });
        }
        if (q.from) {
            qb.andWhere("n.createdAt >= :from", { from: new Date(q.from) });
        }
        if (q.to) {
            qb.andWhere("n.createdAt <= :to", { to: new Date(q.to) });
        }
        qb.orderBy("n.createdAt", "DESC").addOrderBy("n.id", "DESC");
        const page = q.page ?? 1;
        const limit = Math.min(q.limit ?? 20, 100);
        qb.skip((page - 1) * limit).take(limit);
        const [items, total] = await qb.getManyAndCount();
        return { items, meta: { page, limit, total } };
    }
    async create(dto) {
        const entity = this.repo.create({
            category: dto.category ?? notification_entity_1.NotificationCategory.SYSTEM,
            title: dto.title,
            message: dto.message,
            payload: dto.payload,
            sourceId: dto.sourceId,
            itemId: dto.itemId,
            couponId: dto.couponId,
            expiresAt: dto.expiresAt ? new Date(dto.expiresAt) : undefined,
            tags: dto.tags,
            importance: dto.importance ?? 0,
        });
        return this.repo.save(entity);
    }
    async get(id) {
        const notification = await this.repo.findOne({ where: { id } });
        if (!notification)
            throw new common_1.NotFoundException("Notification not found");
        return notification;
    }
    async remove(id) {
        const notification = await this.get(id);
        await this.repo.remove(notification);
        return { ok: true };
    }
};
exports.NotificationsService = NotificationsService;
exports.NotificationsService = NotificationsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(notification_entity_1.Notification)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], NotificationsService);
