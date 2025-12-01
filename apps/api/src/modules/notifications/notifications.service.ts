import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import {
  Notification,
  NotificationCategory,
} from "../../entities/notification.entity";
import { CreateNotificationDto, ListNotificationsDto } from "./dto";

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private readonly repo: Repository<Notification>
  ) {}

  async paginate(q: ListNotificationsDto) {
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

  async create(dto: CreateNotificationDto) {
    const entity = this.repo.create({
      category: dto.category ?? NotificationCategory.SYSTEM,
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

  async get(id: number) {
    const notification = await this.repo.findOne({ where: { id } });
    if (!notification) throw new NotFoundException("Notification not found");
    return notification;
  }

  async remove(id: number) {
    const notification = await this.get(id);
    await this.repo.remove(notification);
    return { ok: true };
  }
}

