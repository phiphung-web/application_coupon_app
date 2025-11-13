import { BaseEntity } from "typeorm";
export declare class ProductCoupon extends BaseEntity {
    id: number;
    productId: number;
    couponId: string;
    isPrimary: boolean;
    createdAt: Date;
}
