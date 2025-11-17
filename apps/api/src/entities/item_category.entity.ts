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
import { Item } from "./item.entity";

@Entity("item_categories")
export class ItemCategory extends BaseEntity {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 100 })
  name!: string;

  @Column({ name: "parent_id", nullable: true })
  parentId?: number;

  @ManyToOne(() => ItemCategory, (cat) => cat.children, { onDelete: "SET NULL" })
  @JoinColumn({ name: "parent_id" })
  parent?: ItemCategory;

  @OneToMany(() => ItemCategory, (cat) => cat.parent)
  children!: ItemCategory[];

  @Column({ name: "image_url", length: 255, nullable: true })
  imageUrl?: string;

  @OneToMany(() => Item, (item) => item.category)
  items!: Item[];

  @CreateDateColumn({ name: "created_at" })
  createdAt!: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt!: Date;
}
