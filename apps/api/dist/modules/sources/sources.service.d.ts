import { Repository } from "typeorm";
import { Source } from "../../entities/source.entity";
import { CreateSourceDto, SourceHighlightQueryDto, UpdateSourceDto } from "./dto";
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
}
