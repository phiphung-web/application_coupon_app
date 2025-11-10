import 'badge.dart';
import 'category.dart';
import 'product_deal.dart';

/// Model Product theo payload backend (NestJS/TypeORM).
class Product {
  final int id;
  final String name;
  final String? imageUrl;
  final int priceOriginal; // lưu ở cent
  final int? priceCurrent; // lưu ở cent
  final String currency;
  final String? description;
  final String? sourceId;
  final List<Category> categories;
  final List<Badge> badges;
  final ProductDeal? bestDeal;
  final String? primaryCouponId;

  const Product({
    required this.id,
    required this.name,
    required this.priceOriginal,
    required this.currency,
    this.priceCurrent,
    this.imageUrl,
    this.description,
    this.sourceId,
    this.categories = const [],
    this.badges = const [],
    this.bestDeal,
    this.primaryCouponId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      priceOriginal: (json['priceOriginal'] ?? 0) as int,
      priceCurrent: json['priceCurrent'] as int?,
      currency: json['currency'] ?? 'USD',
      description: json['description'],
      sourceId: json['sourceId'],
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((c) => Category.fromJson(c as Map<String, dynamic>))
          .toList(),
      badges: (json['badges'] as List<dynamic>? ?? [])
          .map((b) => Badge.fromJson(b as Map<String, dynamic>))
          .toList(),
      bestDeal: json['bestDeal'] != null
          ? ProductDeal.fromJson(json['bestDeal'] as Map<String, dynamic>)
          : null,
      primaryCouponId: json['primaryCouponId'] as String?,
    );
  }

  int get priceEffective => priceCurrent ?? priceOriginal;

  int get discountValue {
    if (priceCurrent == null) return 0;
    final diff = priceOriginal - priceCurrent!;
    return diff < 0 ? 0 : diff;
  }

  int get discountPercent {
    if (priceCurrent == null || priceOriginal == 0) return 0;
    final pct = 100 - ((priceCurrent! * 100) ~/ priceOriginal);
    return pct.clamp(0, 100);
  }

  bool get isHot =>
      badges.any((b) => b.key.toUpperCase() == 'HOT' || b.priority >= 80);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'priceOriginal': priceOriginal,
    'priceCurrent': priceCurrent,
    'currency': currency,
    'description': description,
    'sourceId': sourceId,
    'categories': categories.map((c) => c.toJson()).toList(),
    'badges': badges.map((b) => b.toJson()).toList(),
    if (bestDeal != null) 'bestDeal': bestDeal!.toJson(),
    'primaryCouponId': primaryCouponId,
  };
}
