import { Repository } from "typeorm";
import { Badge } from "../../entities/badge.entity";
export declare class BadgesService {
    private readonly repo;
    constructor(repo: Repository<Badge>);
    list(): Promise<Badge[]>;
    get(id: number): Promise<Badge>;
    create(data: Partial<Badge>): Promise<Badge>;
    update(id: number, data: Partial<Badge>): Promise<Badge>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
