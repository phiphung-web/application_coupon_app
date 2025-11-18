import 'badge.dart';
import 'category.dart';
import 'product_deal.dart';

/// Model Product theo payload backend (Item + Coupon link).
class Product {
  final int id;
  final String name;
  final String? imageUrl;
  final int priceOriginal; // cent
  final int? priceCurrent; // cent
  final String currency;
  final String? description;
  final String? sourceId;
  final String? itemType;
  final String? itemUrl;
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
    this.itemType,
    this.itemUrl,
    this.categories = const [],
    this.badges = const [],
    this.bestDeal,
    this.primaryCouponId,
  });

  static int _toCents(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return (value * 100).round();
    final parsed = double.tryParse(value.toString());
    return parsed == null ? 0 : (parsed * 100).round();
  }

  static List<Category> _parseCategories(Map<String, dynamic> json) {
    final dynamicCats = json['categories'];
    if (dynamicCats is List) {
      return dynamicCats
          .map((c) => Category.fromJson(c as Map<String, dynamic>))
          .toList();
    }
    if (json['category'] != null) {
      return [Category.fromJson(json['category'] as Map<String, dynamic>)];
    }
    return const [];
  }

  static List<Badge> _parseBadges(Map<String, dynamic> json) {
    final dynamicBadges = json['badges'];
    if (dynamicBadges is List) {
      return dynamicBadges
          .map((b) => Badge.fromJson(b as Map<String, dynamic>))
          .toList();
    }
    if (json['badge'] != null) {
      return [Badge.fromJson(json['badge'] as Map<String, dynamic>)];
    }
    return const [];
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final priceCents =
        _toCents(json['price'] ?? json['priceOriginal'] ?? json['priceCurrent']);
    final bestDeal = json['bestDeal'] != null
        ? ProductDeal.fromJson(json['bestDeal'] as Map<String, dynamic>)
        : null;
    return Product(
      id: json['id'] as int,
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      priceOriginal: priceCents,
      priceCurrent: bestDeal?.after ?? _toCents(json['priceCurrent']),
      currency: json['currency'] ?? 'USD',
      description: json['description'],
      sourceId: json['sourceId']?.toString() ??
          (json['source'] != null ? '${json['source']['id']}' : null),
      itemType: json['itemType']?.toString(),
      itemUrl: json['itemUrl'],
      categories: _parseCategories(json),
      badges: _parseBadges(json),
      bestDeal: bestDeal,
      primaryCouponId: json['primaryCouponId']?.toString(),
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
        'itemType': itemType,
        'itemUrl': itemUrl,
        'categories': categories.map((c) => c.toJson()).toList(),
        'badges': badges.map((b) => b.toJson()).toList(),
        if (bestDeal != null) 'bestDeal': bestDeal!.toJson(),
        'primaryCouponId': primaryCouponId,
      };
}
