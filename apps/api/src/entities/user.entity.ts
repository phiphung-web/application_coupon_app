import {
  BaseEntity,
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";
import { FavoriteItem } from "./favorite_item.entity";
import { FavoriteCoupon } from "./favorite_coupon.entity";
import { FavoriteSource } from "./favorite_source.entity";

export enum UserRole {
  USER = "USER",
  ADMIN = "ADMIN",
}

@Entity("users")
export class User extends BaseEntity {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 100 })
  username!: string;

  @Column({ name: "image_url", length: 255, nullable: true })
  imageUrl?: string;

  @Column({ length: 255, unique: true })
  email!: string;

  @Column({ name: "password_hash", length: 255 })
  passwordHash!: string;

  @Column({ type: "enum", enum: UserRole, default: UserRole.USER })
  role!: UserRole;

  @OneToMany(() => FavoriteItem, (fav) => fav.user)
  favoriteItems!: FavoriteItem[];

  @OneToMany(() => FavoriteCoupon, (fav) => fav.user)
  favoriteCoupons!: FavoriteCoupon[];

  @OneToMany(() => FavoriteSource, (fav) => fav.user)
  favoriteSources!: FavoriteSource[];

  @CreateDateColumn({ name: "created_at" })
  createdAt!: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt!: Date;
}
