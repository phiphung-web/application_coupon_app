import { BaseEntity } from "typeorm";
export type SourceType = "ECOM" | "APP" | "GAME" | "SERVICE" | "OTHER";
export declare class Source extends BaseEntity {
    id: string;
    name: string;
    type: SourceType;
    logoUrl?: string;
    domain?: string;
    packageId?: string;
    bundleId?: string;
    publisher?: string;
    priority: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
    deletedAt?: Date;
}
