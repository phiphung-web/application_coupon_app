import { CategoriesService } from "./categories.service";
import { CategoryQueryDto, CreateCategoryDto, UpdateCategoryDto } from "./dto";
export declare class CategoriesController {
    private readonly svc;
    constructor(svc: CategoriesService);
    list(q: CategoryQueryDto): Promise<{
        items: import("../../entities/category.entity").Category[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    listAll(active: string): Promise<import("../../entities/category.entity").Category[]>;
    tree(active: string): Promise<any[]>;
    get(id: number): Promise<import("../../entities/category.entity").Category>;
    breadcrumbs(id: number): Promise<import("../../entities/category.entity").Category[]>;
    create(dto: CreateCategoryDto): Promise<import("../../entities/category.entity").Category>;
    update(id: number, dto: UpdateCategoryDto): Promise<import("../../entities/category.entity").Category>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
