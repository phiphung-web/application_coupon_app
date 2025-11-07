import { CouponCategoriesService } from "./coupon-categories.service";
export declare class CouponCategoriesController {
    private readonly svc;
    constructor(svc: CouponCategoriesService);
    list(): Promise<import("../../entities/coupon_category.entity").CouponCategory[]>;
    get(id: number): Promise<import("../../entities/coupon_category.entity").CouponCategory>;
    create(body: any): Promise<import("../../entities/coupon_category.entity").CouponCategory>;
    update(id: number, body: any): Promise<import("../../entities/coupon_category.entity").CouponCategory>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
