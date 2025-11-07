import { Repository } from "typeorm";
import { Product } from "../../entities/product.entity";
import { ProductCoupon } from "../../entities/product_coupon.entity";
import { Coupon } from "../../entities/coupon.entity";
import { PricingService } from "./pricing.service";
export declare class PricingController {
    private readonly prodRepo;
    private readonly pcRepo;
    private readonly couponRepo;
    private readonly pricing;
    constructor(prodRepo: Repository<Product>, pcRepo: Repository<ProductCoupon>, couponRepo: Repository<Coupon>, pricing: PricingService);
    bestDeal(productId: number): Promise<{
        bestDeal: {
            after: number;
            saved: number;
            coupon: Coupon;
        } | null;
    }>;
}
