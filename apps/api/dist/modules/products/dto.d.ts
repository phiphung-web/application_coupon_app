export declare class CreateProductDto {
    name: string;
    imageUrl?: string;
    priceOriginal: number;
    priceCurrent?: number;
    description?: string;
    sourceId?: string;
    categoryIds: number[];
    badgeIds?: number[];
    createCoupon?: {
        id?: string;
        title: string;
        code: string;
        discountType: "PERCENT" | "FIXED";
        discountValue: number;
        minSpend?: number;
        maxDiscount?: number;
        endAt?: string;
        sourceId?: string;
    };
}
export declare class UpdateProductDto {
    name?: string;
    imageUrl?: string;
    priceOriginal?: number;
    priceCurrent?: number;
    description?: string;
    sourceId?: string;
    categoryIds?: number[];
    badgeIds?: number[];
}
export declare class LinkCouponDto {
    couponId: string;
    isPrimary: boolean;
}
