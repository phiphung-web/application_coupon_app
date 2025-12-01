import { Repository } from "typeorm";
import { Coupon } from "../../entities/coupon.entity";
import { UpsertCouponDto, CouponQueryDto } from "./dto";
export declare class CouponsService {
    private readonly repo;
    constructor(repo: Repository<Coupon>);
    paginate(q: CouponQueryDto & {
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
