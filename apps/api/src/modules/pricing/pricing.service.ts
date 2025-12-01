import { Injectable } from "@nestjs/common";
import { Item } from "../../entities/item.entity";
import { Coupon, DiscountType } from "../../entities/coupon.entity";

@Injectable()
export class PricingService {
  bestDealForProduct(item: Item, coupons: Coupon[]) {
    const base = item.price ? Number(item.price) : 0;
    if (!base) return null;

    const now = new Date();
    let bestAfter = base;
    let picked: Coupon | null = null;

    for (const coupon of coupons) {
      if (coupon.startDate && coupon.startDate > now) continue;
      if (coupon.endDate && coupon.endDate < now) continue;

      const value = coupon.discountValue
        ? Number(coupon.discountValue)
        : undefined;

      let cut = 0;
      if (
        coupon.discountType === DiscountType.FIXED_AMOUNT &&
        value != null
      ) {
        cut = Math.min(value, base);
      } else if (
        coupon.discountType === DiscountType.PERCENT &&
        value != null
      ) {
        cut = Math.min((base * value) / 100, base);
      } else {
        cut = value ?? 0;
      }

      const after = Math.max(base - cut, 0);
      if (after < bestAfter) {
        bestAfter = after;
        picked = coupon;
      }
    }

    if (!picked) return null;
    return { after: bestAfter, saved: base - bestAfter, coupon: picked };
  }
}
