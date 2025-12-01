import { Repository } from "typeorm";
import { Category } from "../../entities/category.entity";
import { CategoryQueryDto, CreateCategoryDto, UpdateCategoryDto } from "./dto";
export declare class CategoriesService {
    private readonly repo;
    constructor(repo: Repository<Category>);
    paginate(q: CategoryQueryDto): Promise<{
        items: Category[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    listAll(): Promise<Category[]>;
    get(id: number): Promise<Category>;
    create(dto: CreateCategoryDto): Promise<Category>;
    update(id: number, dto: UpdateCategoryDto): Promise<Category>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
    highlights(limit?: number): Promise<{
        itemCount: number;
        id: number;
        name: string;
        parentId?: number;
        parent?: Category;
        children: Category[];
        imageUrl?: string;
        items: import("../../entities/item.entity").Item[];
        createdAt: Date;
        updatedAt: Date;
    }[]>;
    tree(): Promise<any[]>;
    breadcrumbs(id: number): Promise<Category[]>;
}
