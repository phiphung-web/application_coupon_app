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
    listAll(activeOnly?: boolean): Promise<Category[]>;
    get(id: number): Promise<Category>;
    create(dto: CreateCategoryDto): Promise<Category>;
    update(id: number, dto: UpdateCategoryDto): Promise<Category>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
    tree(activeOnly?: boolean): Promise<any[]>;
    breadcrumbs(id: number): Promise<Category[]>;
}
