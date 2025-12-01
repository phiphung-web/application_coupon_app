import {
  BaseEntity,
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";
import { Source } from "./source.entity";
import { Item } from "./item.entity";
import { Coupon } from "./coupon.entity";

export enum NotificationCategory {
  SYSTEM = "SYSTEM",
  EVENT = "EVENT",
  PERSONAL = "PERSONAL",
}

@Entity("notifications")
export class Notification extends BaseEntity {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({
    type: "enum",
    enum: NotificationCategory,
    default: NotificationCategory.SYSTEM,
  })
  category!: NotificationCategory;

  @Column({ length: 255 })
  title!: string;

  @Column("text")
  message!: string;

  @Column({ type: "jsonb", nullable: true })
  payload?: Record<string, any>;

  @Column({ name: "source_id", nullable: true })
  sourceId?: number;

  @ManyToOne(() => Source, { onDelete: "SET NULL" })
  @JoinColumn({ name: "source_id" })
  source?: Source;

  @Column({ name: "item_id", nullable: true })
  itemId?: number;

  @ManyToOne(() => Item, { onDelete: "SET NULL" })
  @JoinColumn({ name: "item_id" })
  item?: Item;

  @Column({ name: "coupon_id", nullable: true })
  couponId?: number;

  @ManyToOne(() => Coupon, { onDelete: "SET NULL" })
  @JoinColumn({ name: "coupon_id" })
  coupon?: Coupon;

  @Column({ name: "tags", type: "text", array: true, nullable: true })
  tags?: string[];

  @Column({ name: "importance", type: "smallint", default: 0 })
  importance!: number;

  @CreateDateColumn({ name: "created_at" })
  createdAt!: Date;

  @Column({ name: "expires_at", type: "timestamptz", nullable: true })
  expiresAt?: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt!: Date;
}

