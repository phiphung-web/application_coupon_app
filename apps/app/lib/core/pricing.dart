import 'dart:math';
import '../models/product.dart';
import '../models/coupon.dart';

/// Kết quả tính giá sau khi áp mã
class PricingResult {
  final int discount; // số tiền được giảm
  final int finalPrice; // giá cuối cùng sau giảm
  final Coupon? coupon; // mã áp dụng (nếu có)

  const PricingResult(this.discount, this.finalPrice, this.coupon);

  /// % giảm so với giá gốc
  int discountPercentFor(int basePrice) {
    if (basePrice <= 0) return 0;
    final pct = (discount * 100) ~/ basePrice;
    return pct.clamp(0, 99);
  }
}

/// Tính giá giảm cho một sản phẩm cụ thể và một coupon
PricingResult pricingFor(Product product, Coupon coupon) {
  // không áp dụng được => không giảm
  if (!_canApply(product, coupon)) {
    return PricingResult(0, product.basePrice, null);
  }

  final rawDiscount = _calcDiscount(product.basePrice, coupon);
  final finalPrice = max(product.basePrice - rawDiscount, 0);
  return PricingResult(rawDiscount, finalPrice, coupon);
}

/// Tính toán giá trị giảm (đã tính cap)
int _calcDiscount(int price, Coupon coupon) {
  final raw = coupon.discountType == 'PERCENT'
      ? (price * coupon.discountValue ~/ 100)
      : coupon.discountValue;

  // Nếu có giới hạn giảm tối đa
  final capped = (coupon.maxDiscount ?? 0) > 0
      ? min(raw, coupon.maxDiscount!)
      : raw;

  return max(capped, 0);
}

/// Kiểm tra mã có thể áp dụng cho sản phẩm không
bool _canApply(Product p, Coupon c) {
  if (c.minSpend != null && p.basePrice < c.minSpend!) return false;
  if (c.categoryId != null && c.categoryId != 0 && c.categoryId != p.categoryId)
    return false;
  if (c.applicableTypes != null &&
      c.applicableTypes!.isNotEmpty &&
      !c.applicableTypes!.contains(p.type))
    return false;
  if (c.expiredAt != null && c.expiredAt!.isBefore(DateTime.now()))
    return false;
  return true;
}

/// Tìm mã giảm tốt nhất trong danh sách cho 1 sản phẩm
PricingResult bestForProduct(Product product, List<Coupon> coupons) {
  Coupon? best;
  int bestDiscount = 0;

  for (final c in coupons) {
    if (!_canApply(product, c)) continue;
    final d = _calcDiscount(product.basePrice, c);
    if (d > bestDiscount) {
      bestDiscount = d;
      best = c;
    }
  }

  final finalPrice = max(product.basePrice - bestDiscount, 0);
  return PricingResult(bestDiscount, finalPrice, best);
}
