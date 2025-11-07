import '../models/product.dart';
import '../models/coupon.dart';

class PricingResult {
  final double finalPrice;
  final double discountAmount;
  final Coupon? coupon;
  const PricingResult({
    required this.finalPrice,
    required this.discountAmount,
    required this.coupon,
  });

  int discountPercentFor(double base) {
    if (base <= 0) return 0;
    final pct = (discountAmount / base) * 100.0;
    return pct.isNaN ? 0 : pct.round().clamp(0, 100);
  }
}

bool _canApply(Product p, Coupon c) {
  if (!c.isActive) return false;
  if (c.expiredAt != null && c.expiredAt!.isBefore(DateTime.now()))
    return false;
  if (c.categoryId != null && c.categoryId != 0 && c.categoryId != p.categoryId)
    return false;
  if (c.minSpend != null && p.basePrice < c.minSpend!) return false;
  return true;
}

double _rawDiscount(double price, Coupon c) {
  final raw = c.discountType.toUpperCase() == 'PERCENT'
      ? price * (c.discountValue / 100.0)
      : c.discountValue;

  // c.maxDiscount có thể null hoặc 0 -> không giới hạn
  double capped;
  if (c.maxDiscount == null || c.maxDiscount == 0) {
    capped = raw;
  } else {
    // tránh dùng math.min (trả về num), tự so sánh để ra double
    capped = raw < c.maxDiscount! ? raw : c.maxDiscount!;
  }

  // tránh dùng math.max (trả về num)
  return capped < 0 ? 0.0 : capped;
}

/// Tính mã tốt nhất cho 1 sản phẩm từ danh sách coupon.
PricingResult bestForProduct(Product p, List<Coupon> coupons) {
  Coupon? best;
  double bestAmt = 0.0;

  for (final c in coupons) {
    if (!_canApply(p, c)) continue;
    final d = _rawDiscount(p.basePrice, c);
    if (d > bestAmt) {
      bestAmt = d;
      best = c;
    }
  }

  // tránh dùng math.max (num). Dùng so sánh để ra double
  final fp = p.basePrice - bestAmt;
  final finalPrice = fp < 0 ? 0.0 : fp;

  return PricingResult(
    finalPrice: finalPrice,
    discountAmount: bestAmt,
    coupon: best,
  );
}
