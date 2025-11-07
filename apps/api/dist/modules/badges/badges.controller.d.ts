import { BadgesService } from "./badges.service";
export declare class BadgesController {
    private readonly svc;
    constructor(svc: BadgesService);
    list(): Promise<import("../../entities/badge.entity").Badge[]>;
    get(id: number): Promise<import("../../entities/badge.entity").Badge>;
    create(body: any): Promise<import("../../entities/badge.entity").Badge>;
    update(id: number, body: any): Promise<import("../../entities/badge.entity").Badge>;
    remove(id: number): Promise<{
        ok: boolean;
    }>;
}
