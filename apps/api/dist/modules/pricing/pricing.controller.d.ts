import { Repository } from "typeorm";
import { Item } from "../../entities/item.entity";
import { ItemCouponLink } from "../../entities/item_coupon_link.entity";
import { Coupon } from "../../entities/coupon.entity";
import { PricingService } from "./pricing.service";
export declare class PricingController {
    private readonly itemRepo;
    private readonly linkRepo;
    private readonly couponRepo;
    private readonly pricing;
    constructor(itemRepo: Repository<Item>, linkRepo: Repository<ItemCouponLink>, couponRepo: Repository<Coupon>, pricing: PricingService);
    bestDeal(itemId: number): Promise<{
        bestDeal: {
            after: number;
            saved: number;
            coupon: Coupon;
        } | null;
    }>;
}
