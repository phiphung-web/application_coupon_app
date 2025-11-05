import { Column, Entity, Index, PrimaryColumn } from "typeorm";

export type DiscountType = "PERCENT" | "FIXED";

@Entity("coupons")
export class Coupon {
  @PrimaryColumn({ length: 64 })
  id: string;

  @Index() @Column({ length: 200 }) title: string;
  @Index() @Column({ length: 64 }) code: string;

  @Column({ type: "varchar", length: 10 })
  discountType: DiscountType;

  @Column("int")
  discountValue: number;

  @Column("int", { nullable: true }) minSpend?: number;
  @Column("int", { nullable: true }) maxDiscount?: number;

  @Column({ type: "timestamptz", nullable: true })
  expiredAt?: Date;

  @Column("int", { nullable: true })
  categoryId?: number;

  @Column({ type: "simple-array", nullable: true })
  applicableTypes?: string[];

  @Column({ nullable: true })
  shopId?: string;

  @Column({ nullable: true })
  imageUrl?: string;

  @Column({ type: "simple-array", nullable: true })
  tags?: string[];

  @Column("int", { nullable: true })
  priority?: number;

  @Column({ nullable: true }) trackingLink?: string;
  @Column({ nullable: true }) deeplink?: string;

  @Column({ default: true }) isActive: boolean;
}
