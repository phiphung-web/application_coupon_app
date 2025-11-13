import { BaseEntity } from "typeorm";
export declare class CouponCategory extends BaseEntity {
    id: number;
    name: string;
    imageUrl?: string;
    parentId?: number;
    priority: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
    deletedAt?: Date;
}
