import {
  Column,
  Entity,
  Index,
  ManyToMany,
  JoinTable,
  ManyToOne,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
} from "typeorm";
import { Category } from "./category.entity";
import { Source } from "./source.entity";
import { Badge } from "./badge.entity";

@Entity("products")
export class Product {
  @PrimaryGeneratedColumn() id!: number;

  @Index() @Column({ length: 200 }) name!: string;
  @Column({ nullable: true }) imageUrl?: string;

  // USD cent
  @Column("int") priceOriginal!: number; // ex: 4999 = $49.99
  @Column("int", { nullable: true }) priceCurrent?: number;
  @Column({ length: 3, default: "USD" }) currency!: string;

  @Column("text", { nullable: true }) description?: string;
  @Index() @Column({ nullable: true }) sourceId?: string;
  @ManyToOne(() => Source, { onDelete: "SET NULL" }) source?: Source;

  @ManyToMany(() => Category, { eager: true })
  @JoinTable({ name: "product_categories" })
  categories!: Category[];

  @ManyToMany(() => Badge, { eager: true })
  @JoinTable({ name: "product_badges" })
  badges!: Badge[];

  @CreateDateColumn() createdAt!: Date;
  @UpdateDateColumn() updatedAt!: Date;
  @DeleteDateColumn() deletedAt?: Date;
}
