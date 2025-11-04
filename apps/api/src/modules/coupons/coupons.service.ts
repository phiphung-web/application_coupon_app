import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Like, Repository } from "typeorm";
import { Coupon } from "../../entities/coupon.entity";
import { Category } from "../../entities/category.entity";
import { Shop } from "../../entities/shop.entity";
import { CouponQuery } from "./dto";

@Injectable()
export class CouponsService {
  constructor(
    @InjectRepository(Coupon) private coupons: Repository<Coupon>,
    @InjectRepository(Category) private categories: Repository<Category>,
    @InjectRepository(Shop) private shops: Repository<Shop>
  ) {}

  async list(qry: CouponQuery) {
    const page = Math.max(1, Number(qry.page) || 1);
    const limit = Math.min(50, Math.max(1, Number(qry.limit) || 20));
    const skip = (page - 1) * limit;

    const where: any = {};
    if (qry.q) where.title = Like(`%${qry.q}%`);
    if (qry.shopId) where.shop = { id: Number(qry.shopId) };
    if (qry.categoryKey) where.category = { key: qry.categoryKey };

    const order: any = {};
    switch (qry.sort) {
      case "endAtDesc":
        order.endAt = "DESC";
        break;
      case "createdDesc":
        order.createdAt = "DESC";
        break;
      default:
        order.endAt = "ASC";
    }

    const [items, total] = await this.coupons.findAndCount({
      where,
      order,
      take: limit,
      skip,
    });

    return { page, limit, total, items };
  }
}
