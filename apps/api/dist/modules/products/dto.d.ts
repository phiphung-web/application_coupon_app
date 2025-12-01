import { ItemType } from "../../entities/item.entity";
import { DiscountType } from "../../entities/coupon.entity";
declare class CreateInlineCouponDto {
    code: string;
    description?: string;
    imageUrl?: string;
    discountType: DiscountType;
    discountValue?: number | null;
    dealUrl?: string;
    badgeId?: number;
    categoryId?: number;
    startDate?: string;
    endDate?: string;
}
export declare class CreateProductDto {
    name: string;
    description?: string;
    imageUrl?: string;
    itemType: ItemType;
    itemUrl?: string;
    price?: number | null;
    sourceId?: number;
    categoryId?: number;
    badgeId?: number;
    createCoupon?: CreateInlineCouponDto;
}
export declare class UpdateProductDto {
    name?: string;
    description?: string;
    imageUrl?: string;
    itemType?: ItemType;
    itemUrl?: string;
    price?: number | null;
    sourceId?: number;
    categoryId?: number;
    badgeId?: number;
}
export declare class LinkCouponDto {
    couponId: number;
    isPrimary: boolean;
}
export {};
