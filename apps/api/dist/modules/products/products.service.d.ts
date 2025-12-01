import { Repository } from "typeorm";
import { Item } from "../../entities/item.entity";
import { Coupon } from "../../entities/coupon.entity";
import { ItemCouponLink } from "../../entities/item_coupon_link.entity";
import { CreateProductDto, LinkCouponDto, ProductQueryDto, UpdateProductDto } from "./dto";
import { PricingService } from "../pricing/pricing.service";
export declare class ProductsService {
    private readonly repo;
    private readonly couponRepo;
    private readonly linkRepo;
    private readonly pricing;
    constructor(repo: Repository<Item>, couponRepo: Repository<Coupon>, linkRepo: Repository<ItemCouponLink>, pricing: PricingService);
    paginate(q: ProductQueryDto & {
        withDeal?: boolean;
    }): Promise<{
        items: Item[];
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
            couponLinks: ItemCouponLink[];
            viewCount: number;
            createdAt: Date;
            updatedAt: Date;
        } | {
            bestDeal: {
                after: number;
                saved: number;
                coupon: Coupon;
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
            couponLinks: ItemCouponLink[];
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
    findOne(id: number, withDeal?: boolean): Promise<Item | {
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
        couponLinks: ItemCouponLink[];
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    } | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: Coupon;
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
        couponLinks: ItemCouponLink[];
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    }>;
    create(dto: CreateProductDto): Promise<Item | {
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
        couponLinks: ItemCouponLink[];
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    } | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: Coupon;
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
        couponLinks: ItemCouponLink[];
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    }>;
    update(id: number, dto: UpdateProductDto): Promise<Item | {
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
        couponLinks: ItemCouponLink[];
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    } | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: Coupon;
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
        couponLinks: ItemCouponLink[];
        viewCount: number;
        createdAt: Date;
        updatedAt: Date;
    }>;
    linkCoupon(itemId: number, dto: LinkCouponDto): Promise<{
        ok: boolean;
    }>;
    unlinkCoupon(itemId: number, couponId: number): Promise<{
        ok: boolean;
    }>;
}
