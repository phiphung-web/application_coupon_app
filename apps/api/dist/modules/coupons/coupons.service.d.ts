import { Repository } from 'typeorm';
import { Coupon } from '../../entities/coupon.entity';
import { Badge } from '../../entities/badge.entity';
import { CouponCategory } from '../../entities/coupon_category.entity';
import { UpsertCouponDto } from './dto';
import { PaginationDto } from '../../common/dtos/pagination.dto';
export declare class CouponsService {
    private readonly repo;
    private readonly badgeRepo;
    private readonly catRepo;
    constructor(repo: Repository<Coupon>, badgeRepo: Repository<Badge>, catRepo: Repository<CouponCategory>);
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
    get(id: string): Promise<Coupon>;
    upsert(dto: UpsertCouponDto): Promise<Coupon>;
    deactivate(id: string): Promise<{
        ok: boolean;
    }>;
}
