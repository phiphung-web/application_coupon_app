import { BaseEntity } from "typeorm";
import { Item } from "./item.entity";
import { Coupon } from "./coupon.entity";
export declare class Badge extends BaseEntity {
    id: number;
    name: string;
    slug?: string;
    iconUrl?: string;
    colorCode?: string;
    items: Item[];
    coupons: Coupon[];
    createdAt: Date;
    updatedAt: Date;
}
