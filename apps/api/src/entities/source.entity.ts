import {
  BaseEntity,
  Column,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  AfterLoad,
} from "typeorm";
import { Item } from "./item.entity";
import { Coupon } from "./coupon.entity";
import { toPublicUrl } from "../common/utils/storage.util";

export enum SourceType {
  ECOM = "ECOM",
  FOOD = "FOOD",
  TRAVEL = "TRAVEL",
  APP = "APP",
}

@Entity("sources")
export class Source extends BaseEntity {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 255 })
  name!: string;

  @Column("text", { nullable: true })
  description?: string;

  @Column({ name: "image_url", length: 255, nullable: true })
  imageUrl?: string;

  @Column({ name: "website_url", length: 255, nullable: true })
  websiteUrl?: string;

  @Column({
    type: "enum",
    enum: SourceType,
    default: SourceType.ECOM,
  })
  type!: SourceType;

  @Column({ type: "int", default: 0 })
  priority!: number;

  @OneToMany(() => Item, (item) => item.source)
  items!: Item[];

  @OneToMany(() => Coupon, (coupon) => coupon.source)
  coupons!: Coupon[];

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
