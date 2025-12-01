import {
  BaseEntity,
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";
import { Source } from "./source.entity";
import { CouponCategory } from "./coupon_category.entity";
import { Badge } from "./badge.entity";
import { ItemCouponLink } from "./item_coupon_link.entity";

export enum DiscountType {
  PERCENT = "PERCENT",
  FIXED_AMOUNT = "FIXED_AMOUNT",
  FREESHIP = "FREESHIP",
  GIFT = "GIFT",
}

@Entity("coupons")
export class Coupon extends BaseEntity {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 100 })
  code!: string;

  @Column("text", { nullable: true })
  description?: string;

  @Column({ name: "image_url", length: 255, nullable: true })
  imageUrl?: string;

  @Column({
    name: "discount_type",
    type: "enum",
    enum: DiscountType,
    default: DiscountType.FIXED_AMOUNT,
  })
  discountType!: DiscountType;

  @Column({
    name: "discount_value",
    type: "decimal",
    precision: 12,
    scale: 2,
    nullable: true,
  })
  discountValue?: string;

  @Column({ name: "deal_url", length: 255, nullable: true })
  dealUrl?: string;

  @Column({ name: "source_id", nullable: true })
  sourceId?: number;

  @ManyToOne(() => Source, (source) => source.coupons, {
    onDelete: "SET NULL",
  })
  @JoinColumn({ name: "source_id" })
  source?: Source;

  @Column({ name: "category_id", nullable: true })
  categoryId?: number;

  @ManyToOne(() => CouponCategory, (category) => category.coupons, {
    onDelete: "SET NULL",
  })
  @JoinColumn({ name: "category_id" })
  category?: CouponCategory;

  @Column({ name: "badge_id", nullable: true })
  badgeId?: number;

  @ManyToOne(() => Badge, (badge) => badge.coupons, { onDelete: "SET NULL" })
  @JoinColumn({ name: "badge_id" })
  badge?: Badge;

  @Column({ name: "start_date", type: "timestamptz", nullable: true })
  startDate?: Date;

  @Column({ name: "end_date", type: "timestamptz", nullable: true })
  endDate?: Date;

  @OneToMany(() => ItemCouponLink, (link) => link.coupon)
  itemLinks!: ItemCouponLink[];

  @CreateDateColumn({ name: "created_at" })
  createdAt!: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt!: Date;
}
