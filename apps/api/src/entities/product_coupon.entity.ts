import {
  Column,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  Unique,
} from "typeorm";

@Entity("product_coupons")
@Unique(["productId", "couponId"])
export class ProductCoupon {
  @PrimaryGeneratedColumn() id!: number;

  @Index() @Column() productId!: number;
  @Index() @Column({ length: 64 }) couponId!: string;

  @Column({ default: false }) isPrimary!: boolean;

  @CreateDateColumn() createdAt!: Date;
}
