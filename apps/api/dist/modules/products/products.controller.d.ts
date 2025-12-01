import { ProductsService } from "./products.service";
import { CreateProductDto, LinkCouponDto, ProductQueryDto, UpdateProductDto } from "./dto";
export declare class ProductsController {
    private readonly svc;
    constructor(svc: ProductsService);
    list(q: ProductQueryDto, withDeal?: string): Promise<{
        items: import("../../entities/item.entity").Item[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    } | {
        items: ({
            bestDeal: null;
            primaryCouponId: null;
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
            viewCount: number;
            createdAt: Date;
            updatedAt: Date;
        } | {
            bestDeal: {
                after: number;
                saved: number;
                coupon: import("../../entities/coupon.entity").Coupon;
            } | null;
            primaryCouponId: number;
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
            viewCount: number;
            createdAt: Date;
            updatedAt: Date;
        })[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    get(id: number, withDeal?: string): Promise<import("../../entities/item.entity").Item | {
        bestDeal: null;
        primaryCouponId: null;
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
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    } | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: import("../../entities/coupon.entity").Coupon;
        } | null;
        primaryCouponId: number;
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
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    }>;
    create(dto: CreateProductDto): Promise<import("../../entities/item.entity").Item | {
        bestDeal: null;
        primaryCouponId: null;
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
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    } | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: import("../../entities/coupon.entity").Coupon;
        } | null;
        primaryCouponId: number;
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
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    }>;
    update(id: number, dto: UpdateProductDto): Promise<import("../../entities/item.entity").Item | {
        bestDeal: null;
        primaryCouponId: null;
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
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    } | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: import("../../entities/coupon.entity").Coupon;
        } | null;
        primaryCouponId: number;
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
        viewCount: number;
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
