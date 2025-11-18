import { Item } from "../../entities/item.entity";
import { Coupon } from "../../entities/coupon.entity";
export declare class PricingService {
    bestDealForProduct(item: Item, coupons: Coupon[]): {
        after: number;
        saved: number;
        coupon: Coupon;
    } | null;
}
