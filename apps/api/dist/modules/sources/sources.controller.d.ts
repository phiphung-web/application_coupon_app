import { SourcesService } from "./sources.service";
import { CreateSourceDto, SourceHighlightQueryDto, UpdateSourceDto } from "./dto";
export declare class SourcesController {
    private readonly svc;
    constructor(svc: SourcesService);
    list(): Promise<import("../../entities/source.entity").Source[]>;
    highlights(q: SourceHighlightQueryDto): Promise<{
        itemCount: number;
        couponCount: number;
        id: number;
        name: string;
        description?: string;
        imageUrl?: string;
        websiteUrl?: string;
        type: import("../../entities/source.entity").SourceType;
        priority: number;
        items: import("../../entities/item.entity").Item[];
        coupons: import("../../entities/coupon.entity").Coupon[];
        createdAt: Date;
        updatedAt: Date;
    }[]>;
    get(id: number): Promise<import("../../entities/source.entity").Source>;
    create(dto: CreateSourceDto): Promise<import("../../entities/source.entity").Source>;
    update(id: number, dto: UpdateSourceDto): Promise<import("../../entities/source.entity").Source>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
