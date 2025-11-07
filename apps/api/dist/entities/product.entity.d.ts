import { Category } from "./category.entity";
import { Source } from "./source.entity";
import { Badge } from "./badge.entity";
export declare class Product {
    id: number;
    name: string;
    imageUrl?: string;
    priceOriginal: number;
    priceCurrent?: number;
    currency: string;
    description?: string;
    sourceId?: string;
    source?: Source;
    categories: Category[];
    badges: Badge[];
    createdAt: Date;
    updatedAt: Date;
    deletedAt?: Date;
}
