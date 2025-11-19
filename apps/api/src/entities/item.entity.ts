import {
  BaseEntity,
  Column,
  CreateDateColumn,
  Entity,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
  JoinColumn,
  AfterLoad,
} from "typeorm";
import { Source } from "./source.entity";
import { ItemCategory } from "./item_category.entity";
import { Badge } from "./badge.entity";
import { ItemCouponLink } from "./item_coupon_link.entity";
import { toPublicUrl } from "../common/utils/storage.util";

export enum ItemType {
  PRODUCT = "PRODUCT",
  APP = "APP",
  GAME = "GAME",
  SERVICE = "SERVICE",
}

@Entity("items")
export class Item extends BaseEntity {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 255 })
  name!: string;

  @Column("text", { nullable: true })
  description?: string;

  @Column({ name: "image_url", length: 255, nullable: true })
  imageUrl?: string;

  @Column({
    name: "item_type",
    type: "enum",
    enum: ItemType,
    default: ItemType.PRODUCT,
  })
  itemType!: ItemType;

  @Column({ name: "item_url", length: 255, nullable: true })
  itemUrl?: string;

  @Column({
    type: "decimal",
    precision: 12,
    scale: 2,
    nullable: true,
  })
  price?: string;

  @Column({ name: "source_id", nullable: true })
  sourceId?: number;

  @ManyToOne(() => Source, (source) => source.items, {
    onDelete: "SET NULL",
  })
  @JoinColumn({ name: "source_id" })
  source?: Source;

  @Column({ name: "category_id", nullable: true })
  categoryId?: number;

  @ManyToOne(() => ItemCategory, (category) => category.items, {
    onDelete: "SET NULL",
  })
  @JoinColumn({ name: "category_id" })
  category?: ItemCategory;

  @Column({ name: "badge_id", nullable: true })
  badgeId?: number;

  @ManyToOne(() => Badge, (badge) => badge.items, { onDelete: "SET NULL" })
  @JoinColumn({ name: "badge_id" })
  badge?: Badge;

  @OneToMany(() => ItemCouponLink, (link) => link.item)
  couponLinks!: ItemCouponLink[];

  @Column({ name: "view_count", type: "int", default: 0 })
  viewCount!: number;

  @CreateDateColumn({ name: "created_at" })
  createdAt!: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt!: Date;

  @AfterLoad()
  hydrateUrls() {
    if (this.imageUrl) {
      this.imageUrl = toPublicUrl(this.imageUrl);
    }
  }
}
