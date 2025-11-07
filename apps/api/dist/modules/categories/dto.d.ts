import { PaginationDto } from '../../common/dtos/pagination.dto';
export declare class CreateCategoryDto {
    name: string;
    imageUrl?: string;
    parentId?: number;
    priority?: number;
    isActive?: boolean;
}
export declare class UpdateCategoryDto {
    name?: string;
    imageUrl?: string;
    parentId?: number;
    priority?: number;
    isActive?: boolean;
}
export declare class CategoryQueryDto extends PaginationDto {
    parentId?: number;
    active?: boolean;
}
