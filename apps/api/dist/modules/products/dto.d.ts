import { ItemType } from "../../entities/item.entity";
import { DiscountType } from "../../entities/coupon.entity";
import { PaginationDto } from "../../common/dtos/pagination.dto";
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
}
export declare class ProductQueryDto extends PaginationDto {
    itemType?: ItemType;
    minPrice?: number;
    maxPrice?: number;
    hasCoupon?: string;
}
export {};
