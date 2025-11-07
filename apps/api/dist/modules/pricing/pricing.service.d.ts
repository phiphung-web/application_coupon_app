import { Product } from "../../entities/product.entity";
import { Coupon } from "../../entities/coupon.entity";
export declare class PricingService {
    bestDealForProduct(p: Product, coupons: Coupon[]): {
        after: number;
        saved: number;
        coupon: Coupon;
    } | null;
}
