import { BaseEntity } from "typeorm";
import { User } from "./user.entity";
import { Coupon } from "./coupon.entity";
export declare class FavoriteCoupon extends BaseEntity {
    userId: number;
    couponId: number;
    user: User;
    coupon: Coupon;
}
