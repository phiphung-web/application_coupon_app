import { SourcesService } from "./sources.service";
import { CreateSourceDto, UpdateSourceDto } from "./dto";
export declare class SourcesController {
    private readonly svc;
    constructor(svc: SourcesService);
    list(): Promise<import("../../entities/source.entity").Source[]>;
    get(id: string): Promise<import("../../entities/source.entity").Source>;
    create(dto: CreateSourceDto): Promise<import("../../entities/source.entity").Source>;
    update(id: string, dto: UpdateSourceDto): Promise<import("../../entities/source.entity").Source>;
    remove(id: string): Promise<{
        ok: boolean;
    }>;
}
