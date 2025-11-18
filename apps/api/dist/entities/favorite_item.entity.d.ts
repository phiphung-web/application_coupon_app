import { BaseEntity } from "typeorm";
import { User } from "./user.entity";
import { Item } from "./item.entity";
export declare class FavoriteItem extends BaseEntity {
    userId: number;
    itemId: number;
    user: User;
    item: Item;
}
