import {
  Column,
  Entity,
  Index,
  ManyToMany,
  JoinTable,
  PrimaryColumn,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
} from "typeorm";
import { Badge } from "./badge.entity";
import { CouponCategory } from "./coupon_category.entity";

export type DiscountType = "PERCENT" | "FIXED";

@Entity("coupons")
export class Coupon {
  @PrimaryColumn({ length: 64 }) id!: string;

  @Index() @Column({ length: 200 }) title!: string;
  @Index() @Column({ length: 64 }) code!: string;

  @Column({ type: "enum", enum: ["PERCENT", "FIXED"] })
  discountType!: DiscountType;
  @Column("int") discountValue!: number; // cent nếu FIXED, % nếu PERCENT
  @Column("int", { nullable: true }) minSpend?: number;
  @Column("int", { nullable: true }) maxDiscount?: number;

  @Column({ type: "timestamptz", nullable: true }) endAt?: Date;

  @Index() @Column({ nullable: true }) sourceId?: string;
  @Column({ nullable: true }) imageUrl?: string;

  @ManyToMany(() => CouponCategory, { eager: true })
  @JoinTable({ name: "coupon_categories_map" })
  categories!: CouponCategory[];

  @ManyToMany(() => Badge, { eager: true })
  @JoinTable({ name: "coupon_badges" })
  badges!: Badge[];

  @Column("int", { nullable: true }) priority?: number;
  @Column({ nullable: true }) trackingLink?: string;
  @Column({ nullable: true }) deeplink?: string;

  @Index() @Column({ default: true }) isActive!: boolean;

  @CreateDateColumn() createdAt!: Date;
  @UpdateDateColumn() updatedAt!: Date;
  @DeleteDateColumn() deletedAt?: Date;
}
