import { BaseEntity, Entity, JoinColumn, ManyToOne, PrimaryColumn } from "typeorm";
import { User } from "./user.entity";
import { Coupon } from "./coupon.entity";

@Entity("favorite_coupons")
export class FavoriteCoupon extends BaseEntity {
  @PrimaryColumn({ name: "user_id" })
  userId!: number;

  @PrimaryColumn({ name: "coupon_id" })
  couponId!: number;

  @ManyToOne(() => User, (user) => user.favoriteCoupons, {
    onDelete: "CASCADE",
  })
  @JoinColumn({ name: "user_id" })
  user!: User;

  @ManyToOne(() => Coupon, { onDelete: "CASCADE" })
  @JoinColumn({ name: "coupon_id" })
  coupon!: Coupon;
}
