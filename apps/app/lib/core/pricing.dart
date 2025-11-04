import 'dart:math';
import '../models/coupon.dart';
import '../models/product.dart';

class PricingResult {
  final int discount;
  final int finalPrice;
  final Coupon? coupon;
  const PricingResult({required this.discount, required this.finalPrice, this.coupon});
}

int _calcDiscount(int price, Coupon c) {
  final raw = c.discountType == DiscountType.percent ? (price * c.discountValue ~/ 100) : c.discountValue;
  final cap = c.maxDiscount ?? raw;
  return max(0, min(raw, cap));
}

bool _canApply(Product p, Coupon c) {
  if (c.minOrder != null && p.basePrice < c.minOrder!) return false;
  if (c.shopId != null && c.shopId != p.shopId) return false;
  if (c.categoryId != null && c.categoryId != p.categoryId && !c.categoryIds.contains(p.categoryId)) return false;
  if (c.applicableTypes.isNotEmpty && !c.applicableTypes.contains(p.type)) return false;
  if (c.endAt.isBefore(DateTime.now())) return false;
  return true;
}

PricingResult bestForProduct(Product p, List<Coupon> coupons) {
  Coupon? best;
  var bestDiscount = 0;
  for (final c in coupons) {
    if (!_canApply(p, c)) continue;
    final d = _calcDiscount(p.basePrice, c);
    if (d > bestDiscount) { best = c; bestDiscount = d; }
  }
  return PricingResult(discount: bestDiscount, finalPrice: max(0, p.basePrice - bestDiscount), coupon: best);
}
