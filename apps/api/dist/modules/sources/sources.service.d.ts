import { Repository } from "typeorm";
import { Source } from "../../entities/source.entity";
import { CreateSourceDto, UpdateSourceDto } from "./dto";
export declare class SourcesService {
    private readonly repo;
    constructor(repo: Repository<Source>);
    list(): Promise<Source[]>;
    get(id: string): Promise<Source>;
    create(dto: CreateSourceDto): Promise<Source>;
    update(id: string, dto: UpdateSourceDto): Promise<Source>;
    remove(id: string): Promise<{
        ok: boolean;
    }>;
}
