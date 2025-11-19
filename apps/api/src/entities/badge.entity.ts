import {
  BaseEntity,
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
  AfterLoad,
} from "typeorm";
import { Item } from "./item.entity";
import { Coupon } from "./coupon.entity";
import { toPublicUrl } from "../common/utils/storage.util";

@Entity("badges")
export class Badge extends BaseEntity {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 50 })
  name!: string;

  @Column({ length: 50, unique: true, nullable: true })
  slug?: string;

  @Column({ name: "icon_url", length: 255, nullable: true })
  iconUrl?: string;

  @Column({ name: "color_code", length: 7, nullable: true })
  colorCode?: string;

  @OneToMany(() => Item, (item) => item.badge)
  items!: Item[];

  @OneToMany(() => Coupon, (coupon) => coupon.badge)
  coupons!: Coupon[];

  @CreateDateColumn({ name: "created_at" })
  createdAt!: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt!: Date;

  @AfterLoad()
  hydrateUrls() {
    if (this.iconUrl) {
      this.iconUrl = toPublicUrl(this.iconUrl);
    }
  }
}
