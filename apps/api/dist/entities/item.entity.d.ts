import { BaseEntity } from "typeorm";
import { Source } from "./source.entity";
import { ItemCategory } from "./item_category.entity";
import { Badge } from "./badge.entity";
import { ItemCouponLink } from "./item_coupon_link.entity";
export declare enum ItemType {
    PRODUCT = "PRODUCT",
    APP = "APP",
    GAME = "GAME",
    SERVICE = "SERVICE"
}
export declare class Item extends BaseEntity {
    id: number;
    name: string;
    description?: string;
    imageUrl?: string;
    itemType: ItemType;
    itemUrl?: string;
    price?: string;
    sourceId?: number;
    source?: Source;
    categoryId?: number;
    category?: ItemCategory;
    badgeId?: number;
    badge?: Badge;
    couponLinks: ItemCouponLink[];
    createdAt: Date;
    updatedAt: Date;
}
