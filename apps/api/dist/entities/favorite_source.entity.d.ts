import { BaseEntity } from "typeorm";
import { User } from "./user.entity";
import { Source } from "./source.entity";
export declare class FavoriteSource extends BaseEntity {
    userId: number;
    sourceId: number;
    user: User;
    source: Source;
}
