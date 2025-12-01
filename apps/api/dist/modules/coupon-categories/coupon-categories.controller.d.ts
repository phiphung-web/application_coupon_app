import { CouponCategoriesService } from "./coupon-categories.service";
export declare class CouponCategoriesController {
    private readonly svc;
    constructor(svc: CouponCategoriesService);
    list(): Promise<import("../../entities/coupon_category.entity").CouponCategory[]>;
    highlights(limit: number): Promise<{
        couponCount: number;
        id: number;
        name: string;
        description?: string;
        coupons: import("../../entities/coupon.entity").Coupon[];
        createdAt: Date;
        updatedAt: Date;
    }[]>;
    get(id: number): Promise<import("../../entities/coupon_category.entity").CouponCategory>;
    create(body: any): Promise<import("../../entities/coupon_category.entity").CouponCategory>;
    update(id: number, body: any): Promise<import("../../entities/coupon_category.entity").CouponCategory>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
