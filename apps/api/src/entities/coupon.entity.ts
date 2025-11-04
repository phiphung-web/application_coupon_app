import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  Index,
} from "typeorm";
import { Shop } from "./shop.entity";
import { Category } from "./category.entity";

@Entity()
export class Coupon {
  @PrimaryGeneratedColumn()
  id: number;

  @Index()
  @Column()
  title: string;

  @Column()
  code: string;

  @Column({ nullable: true })
  description: string;

  @Column({ type: "datetime" })
  startAt: Date;

  @Index()
  @Column({ type: "datetime" })
  endAt: Date;

  @ManyToOne(() => Shop, (s) => s.coupons, { eager: true })
  shop: Shop;

  @ManyToOne(() => Category, (c) => c.coupons, { eager: true })
  category: Category;

  @CreateDateColumn()
  createdAt: Date;
}
