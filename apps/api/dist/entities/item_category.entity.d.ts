import { BaseEntity } from "typeorm";
import { Item } from "./item.entity";
export declare class ItemCategory extends BaseEntity {
    id: number;
    name: string;
    parentId?: number;
    parent?: ItemCategory;
    children: ItemCategory[];
    imageUrl?: string;
    items: Item[];
    createdAt: Date;
    updatedAt: Date;
}
