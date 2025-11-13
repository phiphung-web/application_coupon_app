import { BaseEntity } from "typeorm";
export declare class Badge extends BaseEntity {
    id: number;
    key: string;
    label: string;
    color?: string;
    bgColor?: string;
    icon?: string;
    priority: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
    deletedAt?: Date;
}
