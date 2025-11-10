import 'coupon.dart';

class ProductDeal {
  final int after;
  final int saved;
  final Coupon coupon;

  const ProductDeal({
    required this.after,
    required this.saved,
    required this.coupon,
  });

  factory ProductDeal.fromJson(Map<String, dynamic> json) => ProductDeal(
        after: (json['after'] ?? 0) as int,
        saved: (json['saved'] ?? 0) as int,
        coupon: Coupon.fromJson(json['coupon'] as Map<String, dynamic>),
      );

  int get discountPercent {
    if (after <= 0 && saved <= 0) return 0;
    final base = after + saved;
    if (base == 0) return 0;
    return (saved * 100 ~/ base).clamp(0, 100);
  }

  Map<String, dynamic> toJson() => {
        'after': after,
        'saved': saved,
        'coupon': coupon.toJson(),
      };
}
