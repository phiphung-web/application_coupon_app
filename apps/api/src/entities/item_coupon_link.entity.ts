import {
  BaseEntity,
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryColumn,
} from "typeorm";
import { Item } from "./item.entity";
import { Coupon } from "./coupon.entity";

@Entity("item_coupon_links")
export class ItemCouponLink extends BaseEntity {
  @PrimaryColumn({ name: "item_id" })
  itemId!: number;

  @PrimaryColumn({ name: "coupon_id" })
  couponId!: number;

  @ManyToOne(() => Item, (item) => item.couponLinks, {
    onDelete: "CASCADE",
  })
  @JoinColumn({ name: "item_id" })
  item!: Item;

  @ManyToOne(() => Coupon, (coupon) => coupon.itemLinks, {
    onDelete: "CASCADE",
  })
  @JoinColumn({ name: "coupon_id" })
  coupon!: Coupon;

  @Column({ name: "is_primary_display", default: false })
  isPrimaryDisplay!: boolean;

  @CreateDateColumn({ name: "linked_at" })
  linkedAt!: Date;
}
