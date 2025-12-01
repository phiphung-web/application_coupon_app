import { CouponsService } from "./coupons.service";
import { PaginationDto } from "../../common/dtos/pagination.dto";
import { UpsertCouponDto } from "./dto";
export declare class CouponsController {
    private readonly svc;
    constructor(svc: CouponsService);
    list(q: PaginationDto, active?: string): Promise<{
        items: import("../../entities/coupon.entity").Coupon[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    get(id: number): Promise<import("../../entities/coupon.entity").Coupon>;
    upsert(dto: UpsertCouponDto): Promise<import("../../entities/coupon.entity").Coupon>;
    deactivate(id: number): Promise<{
        ok: boolean;
    }>;
}
