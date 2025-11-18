import { BaseEntity } from "typeorm";
import { Coupon } from "./coupon.entity";
export declare class CouponCategory extends BaseEntity {
    id: number;
    name: string;
    description?: string;
    coupons: Coupon[];
    createdAt: Date;
    updatedAt: Date;
}
