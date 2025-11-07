export declare enum DiscountTypeDto {
    PERCENT = "PERCENT",
    FIXED = "FIXED"
}
export declare class UpsertCouponDto {
    id?: string;
    title: string;
    code: string;
    discountType: DiscountTypeDto;
    discountValue: number;
    minSpend?: number;
    maxDiscount?: number;
    endAt?: string;
    sourceId?: string;
    imageUrl?: string;
    categoryIds?: number[];
    badgeIds?: number[];
    priority?: number;
    trackingLink?: string;
    deeplink?: string;
    isActive?: boolean;
}
