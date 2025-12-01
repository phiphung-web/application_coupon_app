import 'coupon.dart';

class ProductDeal {
  final int after; // cent
  final int saved; // cent
  final Coupon coupon;

  const ProductDeal({
    required this.after,
    required this.saved,
    required this.coupon,
  });

  static int _toCents(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return (value * 100).round();
    final parsed = double.tryParse(value.toString());
    return parsed == null ? 0 : (parsed * 100).round();
  }

  factory ProductDeal.fromJson(Map<String, dynamic> json) => ProductDeal(
        after: _toCents(json['after']),
        saved: _toCents(json['saved']),
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
