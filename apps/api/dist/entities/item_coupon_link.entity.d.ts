import { BaseEntity } from "typeorm";
import { Item } from "./item.entity";
import { Coupon } from "./coupon.entity";
export declare class ItemCouponLink extends BaseEntity {
    itemId: number;
    couponId: number;
    item: Item;
    coupon: Coupon;
    isPrimaryDisplay: boolean;
    linkedAt: Date;
}
