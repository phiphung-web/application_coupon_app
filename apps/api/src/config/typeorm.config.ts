import { DataSourceOptions } from "typeorm";
import { Item } from "../entities/item.entity";
import { Coupon } from "../entities/coupon.entity";
import { Category } from "../entities/category.entity";
import { CouponCategory } from "../entities/coupon_category.entity";
import { Badge } from "../entities/badge.entity";
import { Source } from "../entities/source.entity";
import { ItemCouponLink } from "../entities/item_coupon_link.entity";
import { User } from "../entities/user.entity";
import { FavoriteItem } from "../entities/favorite_item.entity";
import { FavoriteCoupon } from "../entities/favorite_coupon.entity";
import { FavoriteSource } from "../entities/favorite_source.entity";
import { ItemCategory } from "../entities/item_category.entity";

export const typeormConfig: DataSourceOptions = {
  type: "postgres",
  url: process.env.DATABASE_URL,
  synchronize: false, // bật true khi dev lần đầu, sau đó false + migration
  logging: false,
  entities: [
    Item,
    ItemCategory,
    Coupon,
    Category,
    CouponCategory,
    Badge,
    Source,
    ItemCouponLink,
    User,
    FavoriteItem,
    FavoriteCoupon,
    FavoriteSource,
  ],
  migrations: ["dist/migrations/*.js"],
};
