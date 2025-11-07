import {
  Column,
  Entity,
  Index,
  ManyToOne,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from "typeorm";
import { Category } from "./category.entity";
import { Source } from "./source.entity";

@Entity("products")
export class Product {
  @PrimaryGeneratedColumn()
  id!: number;

  @Index()
  @Column({ length: 200 })
  name!: string;

  @Column({ nullable: true })
  imageUrl?: string;

  @Column("int")
  basePrice!: number;

  @Column("int", { nullable: true })
  originalPrice?: number;

  @Column("int", { nullable: true })
  discountPercent?: number; // auto-calc nếu có original > base

  @Column("int")
  categoryId!: number;

  @ManyToOne(() => Category, { onDelete: "SET NULL" })
  category?: Category;

  @Column({ nullable: true })
  sourceId?: string;

  @ManyToOne(() => Source, { onDelete: "SET NULL" })
  source?: Source;

  @Column("text", { nullable: true })
  description?: string;

  @Index()
  @Column({ default: false })
  isHot: boolean = false;

  @Column({ type: "json", nullable: true })
  badges?: Array<{
    key: string;
    label: string;
    color?: string;
    bgColor?: string;
    icon?: string;
    priority?: number;
  }>;

  @CreateDateColumn() createdAt!: Date;
  @UpdateDateColumn() updatedAt!: Date;
}
