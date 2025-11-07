import { ProductsService } from "./products.service";
import { PaginationDto } from "../../common/dtos/pagination.dto";
import { CreateProductDto, LinkCouponDto, UpdateProductDto } from "./dto";
export declare class ProductsController {
    private readonly svc;
    constructor(svc: ProductsService);
    list(q: PaginationDto, withDeal?: string): Promise<{
        items: any[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    get(id: number, withDeal?: string): Promise<import("../../entities/product.entity").Product | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: import("../../entities/coupon.entity").Coupon;
        } | null;
        primaryCouponId: string | null;
        id: number;
        name: string;
        imageUrl?: string;
        priceOriginal: number;
        priceCurrent?: number;
        currency: string;
        description?: string;
        sourceId?: string;
        source?: import("../../entities/source.entity").Source;
        categories: import("../../entities/category.entity").Category[];
        badges: import("../../entities/badge.entity").Badge[];
        createdAt: Date;
        updatedAt: Date;
        deletedAt?: Date;
    }>;
    create(dto: CreateProductDto): Promise<import("../../entities/product.entity").Product | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: import("../../entities/coupon.entity").Coupon;
        } | null;
        primaryCouponId: string | null;
        id: number;
        name: string;
        imageUrl?: string;
        priceOriginal: number;
        priceCurrent?: number;
        currency: string;
        description?: string;
        sourceId?: string;
        source?: import("../../entities/source.entity").Source;
        categories: import("../../entities/category.entity").Category[];
        badges: import("../../entities/badge.entity").Badge[];
        createdAt: Date;
        updatedAt: Date;
        deletedAt?: Date;
    }>;
    update(id: number, dto: UpdateProductDto): Promise<import("../../entities/product.entity").Product | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: import("../../entities/coupon.entity").Coupon;
        } | null;
        primaryCouponId: string | null;
        id: number;
        name: string;
        imageUrl?: string;
        priceOriginal: number;
        priceCurrent?: number;
        currency: string;
        description?: string;
        sourceId?: string;
        source?: import("../../entities/source.entity").Source;
        categories: import("../../entities/category.entity").Category[];
        badges: import("../../entities/badge.entity").Badge[];
        createdAt: Date;
        updatedAt: Date;
        deletedAt?: Date;
    }>;
    link(id: number, dto: LinkCouponDto): Promise<{
        ok: boolean;
    }>;
    unlink(id: number, couponId: string): Promise<{
        ok: boolean;
    }>;
}
