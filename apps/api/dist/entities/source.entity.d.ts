import { BaseEntity } from "typeorm";
import { Item } from "./item.entity";
import { Coupon } from "./coupon.entity";
export declare enum SourceType {
    ECOM = "ECOM",
    FOOD = "FOOD",
    TRAVEL = "TRAVEL",
    APP = "APP"
}
export declare class Source extends BaseEntity {
    id: number;
    name: string;
    description?: string;
    imageUrl?: string;
    websiteUrl?: string;
    type: SourceType;
    priority: number;
    items: Item[];
    coupons: Coupon[];
    createdAt: Date;
    updatedAt: Date;
    hydrateUrls(): void;
}
