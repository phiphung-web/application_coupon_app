import { Repository } from "typeorm";
import { Coupon } from "../../entities/coupon.entity";
import { UpsertCouponDto } from "./dto";
import { PaginationDto } from "../../common/dtos/pagination.dto";
export declare class CouponsService {
    private readonly repo;
    constructor(repo: Repository<Coupon>);
    paginate(q: PaginationDto & {
        active?: string;
    }): Promise<{
        items: Coupon[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    get(id: number): Promise<Coupon>;
    upsert(dto: UpsertCouponDto): Promise<Coupon>;
    deactivate(id: number): Promise<{
        ok: boolean;
    }>;
}
