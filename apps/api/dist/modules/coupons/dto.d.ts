import { DiscountType } from "../../entities/coupon.entity";
export declare class UpsertCouponDto {
    id?: number;
    code: string;
    description?: string;
    imageUrl?: string;
    discountType: DiscountType;
    discountValue?: number | null;
    dealUrl?: string;
    sourceId?: number;
    categoryId?: number;
    badgeId?: number;
    startDate?: string;
    endDate?: string;
}
