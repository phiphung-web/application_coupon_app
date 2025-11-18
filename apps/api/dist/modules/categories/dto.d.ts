import { PaginationDto } from "../../common/dtos/pagination.dto";
export declare class CreateCategoryDto {
    name: string;
    imageUrl?: string;
    parentId?: number;
}
export declare class UpdateCategoryDto {
    name?: string;
    imageUrl?: string;
    parentId?: number;
}
export declare class CategoryQueryDto extends PaginationDto {
    parentId?: number;
}
