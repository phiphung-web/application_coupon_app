import { SourcesService } from "./sources.service";
import { CreateSourceDto, UpdateSourceDto } from "./dto";
export declare class SourcesController {
    private readonly svc;
    constructor(svc: SourcesService);
    list(): Promise<import("../../entities/source.entity").Source[]>;
    get(id: number): Promise<import("../../entities/source.entity").Source>;
    create(dto: CreateSourceDto): Promise<import("../../entities/source.entity").Source>;
    update(id: number, dto: UpdateSourceDto): Promise<import("../../entities/source.entity").Source>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
