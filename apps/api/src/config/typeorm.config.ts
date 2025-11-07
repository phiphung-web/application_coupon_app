import { DataSourceOptions } from "typeorm";
import { Product } from "../entities/product.entity";
import { Coupon } from "../entities/coupon.entity";
import { Category } from "../entities/category.entity";
import { CouponCategory } from "../entities/coupon_category.entity";
import { Badge } from "../entities/badge.entity";
import { Source } from "../entities/source.entity";
import { ProductCoupon } from "../entities/product_coupon.entity";

export const typeormConfig: DataSourceOptions = {
  type: "postgres",
  url: process.env.DATABASE_URL,
  synchronize: false, // bật true khi dev lần đầu, sau đó false + migration
  logging: false,
  entities: [
    Product,
    Coupon,
    Category,
    CouponCategory,
    Badge,
    Source,
    ProductCoupon,
  ],
  migrations: ["dist/migrations/*.js"],
};
