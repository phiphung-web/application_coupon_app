import 'badge.dart';
import 'coupon_category.dart';

class Coupon {
  final String id;
  final String title;
  final String code;
  final String discountType; // PERCENT | FIXED
  final int discountValue;
  final int? minSpend;
  final int? maxDiscount;
  final DateTime? endAt;
  final String? sourceId;
  final String? imageUrl;
  final List<CouponCategory> categories;
  final List<Badge> badges;
  final int? priority;
  final String? trackingLink;
  final String? deeplink;
  final bool isActive;

  const Coupon({
    required this.id,
    required this.title,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minSpend,
    this.maxDiscount,
    this.endAt,
    this.sourceId,
    this.imageUrl,
    this.categories = const [],
    this.badges = const [],
    this.priority,
    this.trackingLink,
    this.deeplink,
    this.isActive = true,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: json['id'].toString(),
        title: json['title'] ?? '',
        code: json['code'] ?? '',
        discountType: json['discountType'] ?? 'FIXED',
        discountValue: (json['discountValue'] ?? 0) as int,
        minSpend: json['minSpend'] as int?,
        maxDiscount: json['maxDiscount'] as int?,
        endAt: json['endAt'] != null
            ? DateTime.tryParse(json['endAt'].toString())
            : null,
        sourceId: json['sourceId'],
        imageUrl: json['imageUrl'],
        categories: (json['categories'] as List<dynamic>? ?? [])
            .map((e) => CouponCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
        badges: (json['badges'] as List<dynamic>? ?? [])
            .map((e) => Badge.fromJson(e as Map<String, dynamic>))
            .toList(),
        priority: json['priority'] is int
            ? json['priority'] as int
            : int.tryParse('${json['priority']}'),
        trackingLink: json['trackingLink'],
        deeplink: json['deeplink'],
        isActive: json['isActive'] ?? true,
      );

  bool get isPercent => discountType.toUpperCase() == 'PERCENT';

  int? get primaryCategoryId =>
      categories.isEmpty ? null : categories.first.id;

  DateTime? get expiredAt => endAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue,
        'minSpend': minSpend,
        'maxDiscount': maxDiscount,
        'endAt': endAt?.toIso8601String(),
        'sourceId': sourceId,
        'imageUrl': imageUrl,
        'categories': categories.map((c) => c.toJson()).toList(),
        'badges': badges.map((b) => b.toJson()).toList(),
        'priority': priority,
        'trackingLink': trackingLink,
        'deeplink': deeplink,
        'isActive': isActive,
      };
}
