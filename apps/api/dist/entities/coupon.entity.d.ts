import { BaseEntity } from "typeorm";
import { Source } from "./source.entity";
import { CouponCategory } from "./coupon_category.entity";
import { Badge } from "./badge.entity";
import { ItemCouponLink } from "./item_coupon_link.entity";
export declare enum DiscountType {
    PERCENT = "PERCENT",
    FIXED_AMOUNT = "FIXED_AMOUNT",
    FREESHIP = "FREESHIP",
    GIFT = "GIFT"
}
export declare class Coupon extends BaseEntity {
    id: number;
    code: string;
    description?: string;
    imageUrl?: string;
    discountType: DiscountType;
    discountValue?: string;
    dealUrl?: string;
    sourceId?: number;
    source?: Source;
    categoryId?: number;
    category?: CouponCategory;
    badgeId?: number;
    badge?: Badge;
    startDate?: Date;
    endDate?: Date;
    itemLinks: ItemCouponLink[];
    createdAt: Date;
    updatedAt: Date;
    hydrateUrls(): void;
}
