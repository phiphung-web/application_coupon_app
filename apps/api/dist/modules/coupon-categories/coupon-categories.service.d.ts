import { Repository } from "typeorm";
import { CouponCategory } from "../../entities/coupon_category.entity";
export declare class CouponCategoriesService {
    private readonly repo;
    constructor(repo: Repository<CouponCategory>);
    list(): Promise<CouponCategory[]>;
    get(id: number): Promise<CouponCategory>;
    create(data: Partial<CouponCategory>): Promise<CouponCategory>;
    update(id: number, data: Partial<CouponCategory>): Promise<CouponCategory>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
    highlights(limit?: number): Promise<{
        couponCount: number;
        id: number;
        name: string;
        description?: string;
        coupons: import("../../entities/coupon.entity").Coupon[];
        createdAt: Date;
        updatedAt: Date;
    }[]>;
}
