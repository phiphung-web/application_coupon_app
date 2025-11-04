import 'dart:math';
import '../models/product.dart';
import '../models/coupon.dart';

class DiscountResult {
  final int discount;
  final int finalPrice;
  final Coupon? coupon;
  const DiscountResult(this.discount, this.finalPrice, this.coupon);
}

/// --------- Helpers: đọc field an toàn, hỗ trợ nhiều tên ---------

int _productPrice(Product p) {
  // ưu tiên basePrice; fallback price
  try {
    return (p as dynamic).basePrice as int;
  } catch (_) {
    final v = (p as dynamic).price as int?;
    return v ?? 0;
  }
}

int _productCategoryId(Product p) {
  try {
    return (p as dynamic).categoryId as int;
  } catch (_) {
    return 0;
  }
}

String? _productType(Product p) {
  try {
    return (p as dynamic).type as String?;
  } catch (_) {
    return null;
  }
}

bool _couponIsPercent(Coupon c) {
  // enum DiscountType.percent | string 'PERCENT'
  try {
    final dt = (c as dynamic).discountType;
    if (dt is Enum) return dt.name.toLowerCase() == 'percent';
    if (dt is String) return dt.toUpperCase() == 'PERCENT';
  } catch (_) {}
  return true; // mặc định coi như % để tránh crash
}

int _couponValue(Coupon c) {
  try {
    return (c as dynamic).discountValue as int;
  } catch (_) {
    try {
      return (c as dynamic).value as int;
    } catch (_) {
      return 0;
    }
  }
}

int? _couponMaxDiscount(Coupon c) {
  try {
    return (c as dynamic).maxDiscount as int?;
  } catch (_) {
    return null;
  }
}

int? _couponMinOrder(Coupon c) {
  try {
    return (c as dynamic).minOrder as int?;
  } catch (_) {
    try {
      return (c as dynamic).minSpend as int?;
    } catch (_) {
      return null;
    }
  }
}

int? _couponCategoryId(Coupon c) {
  try {
    return (c as dynamic).categoryId as int?;
  } catch (_) {
    return null;
  }
}

List<int> _couponCategoryIds(Coupon c) {
  try {
    return ((c as dynamic).categoryIds as List?)?.cast<int>() ?? const <int>[];
  } catch (_) {
    return const <int>[];
  }
}

List<String> _couponApplicableTypes(Coupon c) {
  try {
    return ((c as dynamic).applicableTypes as List?)?.cast<String>() ??
        const <String>[];
  } catch (_) {
    return const <String>[];
  }
}

DateTime? _couponEndAt(Coupon c) {
  // endAt | expiredAt
  try {
    return (c as dynamic).endAt as DateTime?;
  } catch (_) {
    try {
      return (c as dynamic).expiredAt as DateTime?;
    } catch (_) {
      return null;
    }
  }
}

/// --------- Core logic ---------

int _calcRaw(int price, Coupon c) {
  final isPercent = _couponIsPercent(c);
  final val = _couponValue(c);
  int raw = isPercent ? (price * val ~/ 100) : val;

  final cap = _couponMaxDiscount(c);
  if (cap != null && cap > 0) raw = min(raw, cap);
  // nếu cap == null hoặc == 0 => không giới hạn
  return max(raw, 0);
}

bool _canApply(Product p, Coupon c) {
  final price = _productPrice(p);

  final minOrder = _couponMinOrder(c);
  if (minOrder != null && price < minOrder) return false;

  final pType = _productType(p);
  final types = _couponApplicableTypes(c);
  if (types.isNotEmpty && (pType == null || !types.contains(pType)))
    return false;

  final pCat = _productCategoryId(p);
  final mainCat = _couponCategoryId(c);
  final extraCats = _couponCategoryIds(c);
  if (mainCat != null &&
      mainCat != 0 &&
      mainCat != pCat &&
      !extraCats.contains(pCat))
    return false;

  final endAt = _couponEndAt(c);
  if (endAt != null && endAt.isBefore(DateTime.now())) return false;

  return true;
}

DiscountResult bestDiscount(Product p, List<Coupon> coupons) {
  final price = _productPrice(p);
  Coupon? best;
  var bestDiscount = 0;

  for (final c in coupons) {
    if (!_canApply(p, c)) continue;
    final d = _calcRaw(price, c);
    if (d > bestDiscount) {
      bestDiscount = d;
      best = c;
    }
  }

  final finalPrice = max(price - bestDiscount, 0);
  return DiscountResult(bestDiscount, finalPrice, best);
}
