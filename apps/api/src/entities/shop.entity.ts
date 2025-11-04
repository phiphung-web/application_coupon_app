import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from "typeorm";
import { Coupon } from "./coupon.entity";

@Entity()
export class Shop {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  slug: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  logoUrl: string;

  @OneToMany(() => Coupon, (c) => c.shop)
  coupons: Coupon[];
}
