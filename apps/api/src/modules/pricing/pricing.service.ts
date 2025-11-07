import { Injectable } from '@nestjs/common';
import { Coupon } from '../../entities/coupon.entity';
import { Product } from '../../entities/product.entity';

@Injectable()
export class PricingService {
  private canApply(p: Product, c: Coupon) {
    if (!c.isActive) return false;
    if (c.expiredAt && c.expiredAt < new Date()) return false;
    if (c.categoryId && c.categoryId !== p.categoryId) return false;
    if (c.sourceId && p.sourceId && c.sourceId !== p.sourceId) return false;
    if (c.minSpend && p.basePrice < c.minSpend) return false;
    return true;
  }

  private rawDiscount(price: number, c: Coupon) {
    const raw = c.discountType === 'PERCENT'
      ? price * (c.discountValue / 100)
      : c.discountValue;
    const capped = (c.maxDiscount && c.maxDiscount > 0) ? Math.min(raw, c.maxDiscount) : raw;
    return Math.max(0, capped);
  }

  bestForProduct(p: Product, coupons: Coupon[]) {
    let best: Coupon | null = null;
    let bestAmt = 0;
    for (const c of coupons) {
      if (!this.canApply(p, c)) continue;
      const d = this.rawDiscount(p.basePrice, c);
      if (d > bestAmt) { bestAmt = d; best = c; }
    }
    const finalPrice = Math.max(0, p.basePrice - bestAmt);
    return { finalPrice, discountAmount: bestAmt, coupon: best };
  }
}
