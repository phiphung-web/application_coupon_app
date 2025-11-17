import { BaseEntity, Entity, JoinColumn, ManyToOne, PrimaryColumn } from "typeorm";
import { User } from "./user.entity";
import { Item } from "./item.entity";

@Entity("favorite_items")
export class FavoriteItem extends BaseEntity {
  @PrimaryColumn({ name: "user_id" })
  userId!: number;

  @PrimaryColumn({ name: "item_id" })
  itemId!: number;

  @ManyToOne(() => User, (user) => user.favoriteItems, { onDelete: "CASCADE" })
  @JoinColumn({ name: "user_id" })
  user!: User;

  @ManyToOne(() => Item, { onDelete: "CASCADE" })
  @JoinColumn({ name: "item_id" })
  item!: Item;
}
