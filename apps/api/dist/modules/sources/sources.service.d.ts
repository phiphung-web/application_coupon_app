import { Repository } from "typeorm";
import { Source } from "../../entities/source.entity";
import { CreateSourceDto, UpdateSourceDto } from "./dto";
export declare class SourcesService {
    private readonly repo;
    constructor(repo: Repository<Source>);
    list(): Promise<Source[]>;
    get(id: number): Promise<Source>;
    create(dto: CreateSourceDto): Promise<Source>;
    update(id: number, dto: UpdateSourceDto): Promise<Source>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
