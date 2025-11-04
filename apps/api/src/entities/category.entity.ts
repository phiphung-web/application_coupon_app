import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from "typeorm";
import { Coupon } from "./coupon.entity";

@Entity()
export class Category {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  key: string;

  @Column()
  label: string;

  @OneToMany(() => Coupon, (c) => c.category)
  coupons: Coupon[];
}
