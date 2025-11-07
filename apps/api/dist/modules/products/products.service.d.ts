import { Repository } from "typeorm";
import { Product } from "../../entities/product.entity";
import { Category } from "../../entities/category.entity";
import { Badge } from "../../entities/badge.entity";
import { Coupon } from "../../entities/coupon.entity";
import { ProductCoupon } from "../../entities/product_coupon.entity";
import { CreateProductDto, LinkCouponDto, UpdateProductDto } from "./dto";
import { PaginationDto } from "../../common/dtos/pagination.dto";
import { PricingService } from "../pricing/pricing.service";
export declare class ProductsService {
    private readonly repo;
    private readonly catRepo;
    private readonly badgeRepo;
    private readonly couponRepo;
    private readonly pcRepo;
    private readonly pricing;
    constructor(repo: Repository<Product>, catRepo: Repository<Category>, badgeRepo: Repository<Badge>, couponRepo: Repository<Coupon>, pcRepo: Repository<ProductCoupon>, pricing: PricingService);
    paginate(q: PaginationDto & {
        withDeal?: boolean;
    }): Promise<{
        items: any[];
        meta: {
            page: number;
            limit: number;
            total: number;
        };
    }>;
    findOne(id: number, withDeal?: boolean): Promise<Product | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: Coupon;
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
        categories: Category[];
        badges: Badge[];
        createdAt: Date;
        updatedAt: Date;
        deletedAt?: Date;
    }>;
    create(dto: CreateProductDto): Promise<Product | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: Coupon;
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
        categories: Category[];
        badges: Badge[];
        createdAt: Date;
        updatedAt: Date;
        deletedAt?: Date;
    }>;
    update(id: number, dto: UpdateProductDto): Promise<Product | {
        bestDeal: {
            after: number;
            saved: number;
            coupon: Coupon;
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
        categories: Category[];
        badges: Badge[];
        createdAt: Date;
        updatedAt: Date;
        deletedAt?: Date;
    }>;
    linkCoupon(productId: number, dto: LinkCouponDto): Promise<{
        ok: boolean;
    }>;
    unlinkCoupon(productId: number, couponId: string): Promise<{
        ok: boolean;
    }>;
}
