import { ProductsService } from "./products.service";
import { PaginationDto } from "../../common/dtos/pagination.dto";
import { CreateProductDto, LinkCouponDto, UpdateProductDto } from "./dto";
export declare class ProductsController {
    private readonly svc;
    constructor(svc: ProductsService);
    list(q: PaginationDto, withDeal?: string): Promise<{
        items: import("../../entities/item.entity").Item[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    } | {
        items: {
            bestDeal: {
                after: number;
                saved: number;
                coupon: import("../../entities/coupon.entity").Coupon;
            } | null;
            primaryCouponId: number | null;
            id: number;
            name: string;
            description?: string;
            imageUrl?: string;
            itemType: import("../../entities/item.entity").ItemType;
            itemUrl?: string;
            price?: string;
            sourceId?: number;
            source?: import("../../entities/source.entity").Source;
            categoryId?: number;
            category?: import("../../entities/item_category.entity").ItemCategory;
            badgeId?: number;
            badge?: import("../../entities/badge.entity").Badge;
            couponLinks: import("../../entities/item_coupon_link.entity").ItemCouponLink[];
            createdAt: Date;
            updatedAt: Date;
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    get(id: number, withDeal?: string): Promise<import("../../entities/item.entity").Item | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: import("../../entities/coupon.entity").Coupon;
        } | null;
        primaryCouponId: number | null;
        id: number;
        name: string;
        description?: string;
        imageUrl?: string;
        itemType: import("../../entities/item.entity").ItemType;
        itemUrl?: string;
        price?: string;
        sourceId?: number;
        source?: import("../../entities/source.entity").Source;
        categoryId?: number;
        category?: import("../../entities/item_category.entity").ItemCategory;
        badgeId?: number;
        badge?: import("../../entities/badge.entity").Badge;
        couponLinks: import("../../entities/item_coupon_link.entity").ItemCouponLink[];
        createdAt: Date;
        updatedAt: Date;
    }>;
    create(dto: CreateProductDto): Promise<import("../../entities/item.entity").Item | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: import("../../entities/coupon.entity").Coupon;
        } | null;
        primaryCouponId: number | null;
        id: number;
        name: string;
        description?: string;
        imageUrl?: string;
        itemType: import("../../entities/item.entity").ItemType;
        itemUrl?: string;
        price?: string;
        sourceId?: number;
        source?: import("../../entities/source.entity").Source;
        categoryId?: number;
        category?: import("../../entities/item_category.entity").ItemCategory;
        badgeId?: number;
        badge?: import("../../entities/badge.entity").Badge;
        couponLinks: import("../../entities/item_coupon_link.entity").ItemCouponLink[];
        createdAt: Date;
        updatedAt: Date;
    }>;
    update(id: number, dto: UpdateProductDto): Promise<import("../../entities/item.entity").Item | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: import("../../entities/coupon.entity").Coupon;
        } | null;
        primaryCouponId: number | null;
        id: number;
        name: string;
        description?: string;
        imageUrl?: string;
        itemType: import("../../entities/item.entity").ItemType;
        itemUrl?: string;
        price?: string;
        sourceId?: number;
        source?: import("../../entities/source.entity").Source;
        categoryId?: number;
        category?: import("../../entities/item_category.entity").ItemCategory;
        badgeId?: number;
        badge?: import("../../entities/badge.entity").Badge;
        couponLinks: import("../../entities/item_coupon_link.entity").ItemCouponLink[];
        createdAt: Date;
        updatedAt: Date;
    }>;
    link(id: number, dto: LinkCouponDto): Promise<{
        ok: boolean;
    }>;
    unlink(id: number, couponId: number): Promise<{
        ok: boolean;
    }>;
}
