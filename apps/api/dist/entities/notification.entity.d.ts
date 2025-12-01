import { BaseEntity } from "typeorm";
import { Source } from "./source.entity";
import { Item } from "./item.entity";
import { Coupon } from "./coupon.entity";
export declare enum NotificationCategory {
    SYSTEM = "SYSTEM",
    EVENT = "EVENT",
    PERSONAL = "PERSONAL"
}
export declare class Notification extends BaseEntity {
    id: number;
    category: NotificationCategory;
    title: string;
    message: string;
    payload?: Record<string, any>;
    sourceId?: number;
    source?: Source;
    itemId?: number;
    item?: Item;
    couponId?: number;
    coupon?: Coupon;
    tags?: string[];
    importance: number;
    createdAt: Date;
    expiresAt?: Date;
    updatedAt: Date;
}
