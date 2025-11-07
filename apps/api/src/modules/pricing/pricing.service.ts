import { Injectable } from "@nestjs/common";
import { Product } from "../../entities/product.entity";
import { Coupon } from "../../entities/coupon.entity";

@Injectable()
export class PricingService {
  bestDealForProduct(p: Product, coupons: Coupon[]) {
    const base = p.priceCurrent ?? p.priceOriginal;
    let pick: Coupon | null = null;
    let bestAfter = base;

    const now = new Date();

    for (const c of coupons) {
      if (!c.isActive) continue;
      if (c.endAt && c.endAt < now) continue;
      if (c.minSpend && base < c.minSpend) continue;

      let cut = 0;
      if (c.discountType === "FIXED") {
        cut = Math.min(c.discountValue, base);
      } else {
        const raw = Math.floor((base * c.discountValue) / 100);
        cut = Math.min(raw, c.maxDiscount ?? raw);
      }

      const after = Math.max(base - cut, 0);
      if (after < bestAfter) {
        bestAfter = after;
        pick = c;
      }
    }

    if (!pick) return null;
    return { after: bestAfter, saved: base - bestAfter, coupon: pick };
  }
}
