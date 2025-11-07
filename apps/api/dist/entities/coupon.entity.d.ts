import { Badge } from "./badge.entity";
import { CouponCategory } from "./coupon_category.entity";
export type DiscountType = "PERCENT" | "FIXED";
export declare class Coupon {
    id: string;
    title: string;
    code: string;
    discountType: DiscountType;
    discountValue: number;
    minSpend?: number;
    maxDiscount?: number;
    endAt?: Date;
    sourceId?: string;
    imageUrl?: string;
    categories: CouponCategory[];
    badges: Badge[];
    priority?: number;
    trackingLink?: string;
    deeplink?: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
    deletedAt?: Date;
}
