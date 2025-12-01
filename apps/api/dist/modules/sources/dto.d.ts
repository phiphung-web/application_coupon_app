import { SourceType } from "../../entities/source.entity";
export declare class CreateSourceDto {
    name: string;
    description?: string;
    imageUrl?: string;
    websiteUrl?: string;
}
export declare class UpdateSourceDto {
    name?: string;
    description?: string;
    imageUrl?: string;
    websiteUrl?: string;
    type?: SourceType;
    priority?: number;
}
export declare class SourceHighlightQueryDto {
    type?: SourceType;
    limit?: number;
}
