import { BaseEntity } from "typeorm";
import { Item } from "./item.entity";
import { Coupon } from "./coupon.entity";
export declare class Source extends BaseEntity {
    id: number;
    name: string;
    description?: string;
    imageUrl?: string;
    websiteUrl?: string;
    items: Item[];
    coupons: Coupon[];
    createdAt: Date;
    updatedAt: Date;
}
