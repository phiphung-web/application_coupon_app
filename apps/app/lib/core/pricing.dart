import '../models/coupon.dart';
import '../models/product.dart';

class PricingResult {
  final int finalPrice;
  final int discountAmount;
  final Coupon? coupon;

  const PricingResult({
    required this.finalPrice,
    required this.discountAmount,
    required this.coupon,
  });

  int discountPercentFor(int base) {
    if (base <= 0) return 0;
    return ((discountAmount * 100) ~/ base).clamp(0, 100);
  }
}

bool _categoryMatch(Product p, Coupon c) {
  if (c.categories.isEmpty) return true;
  if (p.categories.isEmpty) return false;
  final productCatIds = p.categories.map((cat) => cat.id).toSet();
  return c.categories.any((cat) => productCatIds.contains(cat.id));
}

bool _canApply(Product p, Coupon c) {
  if (!c.isActive) return false;
  if (c.endAt != null && c.endAt!.isBefore(DateTime.now())) return false;
  if (c.sourceId != null &&
      c.sourceId!.isNotEmpty &&
      c.sourceId != p.sourceId) return false;
  if (!_categoryMatch(p, c)) return false;
  if (c.minSpend != null && p.priceEffective < c.minSpend!) return false;
  return true;
}

int _rawDiscount(int price, Coupon c) {
  final isPercent = c.isPercent;
  final raw = isPercent ? (price * c.discountValue ~/ 100) : c.discountValue;
  final cap = c.maxDiscount;
  final capped = (cap == null || cap == 0) ? raw : raw.clamp(0, cap);
  return capped < 0 ? 0 : capped;
}

PricingResult bestForProduct(Product p, List<Coupon> coupons) {
  Coupon? best;
  var bestAmt = 0;

  for (final c in coupons) {
    if (!_canApply(p, c)) continue;
    final d = _rawDiscount(p.priceEffective, c);
    if (d > bestAmt) {
      bestAmt = d;
      best = c;
    }
  }

  final fp = p.priceEffective - bestAmt;
  final finalPrice = fp < 0 ? 0 : fp;
  return PricingResult(
    finalPrice: finalPrice,
    discountAmount: bestAmt,
    coupon: best,
  );
}
