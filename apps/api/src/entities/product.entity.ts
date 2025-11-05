import {
  Column,
  Entity,
  Index,
  ManyToOne,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Category } from "./category.entity";
import { Shop } from "./shop.entity";

@Entity("products")
export class Product {
  @PrimaryGeneratedColumn()
  id: number;

  @Index()
  @Column({ length: 200 })
  name: string;

  @Column({ nullable: true })
  imageUrl?: string;

  // giá hiện tại (chưa áp mã)
  @Column("int")
  basePrice: number;

  // giá gốc/niêm yết (nullable)
  @Column("int", { nullable: true })
  originalPrice?: number;

  // % OFF dùng hiển thị/sort (nullable)
  @Column("int", { nullable: true })
  discountPercent?: number;

  @Column("int")
  categoryId: number;

  @ManyToOne(() => Category, { onDelete: "SET NULL" })
  category?: Category;

  @Column({ nullable: true })
  shopId?: string;

  @ManyToOne(() => Shop, { onDelete: "SET NULL" })
  shop?: Shop;

  @Column("text", { nullable: true })
  description?: string;

  @Index()
  @Column({ default: false })
  isHot: boolean;
}
