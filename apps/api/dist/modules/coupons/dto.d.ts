import { DiscountType } from "../../entities/coupon.entity";
import { PaginationDto } from "../../common/dtos/pagination.dto";
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
export declare class CouponQueryDto extends PaginationDto {
    discountType?: DiscountType;
    expiresFrom?: string;
    expiresTo?: string;
}
