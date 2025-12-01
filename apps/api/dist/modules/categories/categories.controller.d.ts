import { CategoriesService } from "./categories.service";
import { CategoryQueryDto, CreateCategoryDto, UpdateCategoryDto } from "./dto";
export declare class CategoriesController {
    private readonly svc;
    constructor(svc: CategoriesService);
    list(q: CategoryQueryDto): Promise<{
        items: import("../../entities/item_category.entity").ItemCategory[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    highlights(limit: number): Promise<{
        itemCount: number;
        id: number;
        name: string;
        parentId?: number;
        parent?: import("../../entities/item_category.entity").ItemCategory;
        children: import("../../entities/item_category.entity").ItemCategory[];
        imageUrl?: string;
        items: import("../../entities/item.entity").Item[];
        createdAt: Date;
        updatedAt: Date;
    }[]>;
    listAll(): Promise<import("../../entities/item_category.entity").ItemCategory[]>;
    tree(): Promise<any[]>;
    get(id: number): Promise<import("../../entities/item_category.entity").ItemCategory>;
    breadcrumbs(id: number): Promise<import("../../entities/item_category.entity").ItemCategory[]>;
    create(dto: CreateCategoryDto): Promise<import("../../entities/item_category.entity").ItemCategory>;
    update(id: number, dto: UpdateCategoryDto): Promise<import("../../entities/item_category.entity").ItemCategory>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
