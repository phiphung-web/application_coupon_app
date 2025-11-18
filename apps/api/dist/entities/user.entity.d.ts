import { BaseEntity } from "typeorm";
import { FavoriteItem } from "./favorite_item.entity";
import { FavoriteCoupon } from "./favorite_coupon.entity";
import { FavoriteSource } from "./favorite_source.entity";
export declare enum UserRole {
    USER = "USER",
    ADMIN = "ADMIN"
}
export declare class User extends BaseEntity {
    id: number;
    username: string;
    imageUrl?: string;
    email: string;
    passwordHash: string;
    role: UserRole;
    favoriteItems: FavoriteItem[];
    favoriteCoupons: FavoriteCoupon[];
    favoriteSources: FavoriteSource[];
    createdAt: Date;
    updatedAt: Date;
}
