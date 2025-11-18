import 'badge.dart';
import 'coupon_category.dart';

class Coupon {
  final int id;
  final String title;
  final String code;
  final String discountType; // PERCENT | FIXED_AMOUNT | FREESHIP | GIFT
  final int discountValue; // cent nếu FIXED, %, còn lại 0
  final int? minSpend;
  final int? maxDiscount;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sourceId;
  final String? imageUrl;
  final List<CouponCategory> categories;
  final List<Badge> badges;
  final String? dealUrl;
  final String? trackingLink;
  final String? deeplink;
  final bool isActive;
  final int? priority;

  const Coupon({
    required this.id,
    required this.title,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minSpend,
    this.maxDiscount,
    this.startDate,
    this.endDate,
    this.sourceId,
    this.imageUrl,
    this.categories = const [],
    this.badges = const [],
    this.dealUrl,
    this.trackingLink,
    this.deeplink,
    this.isActive = true,
    this.priority,
  });

  static List<CouponCategory> _parseCategories(Map<String, dynamic> json) {
    final list = json['categories'];
    if (list is List) {
      return list
          .map((e) => CouponCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (json['category'] != null) {
      return [CouponCategory.fromJson(json['category'] as Map<String, dynamic>)];
    }
    return const [];
  }

  static List<Badge> _parseBadges(Map<String, dynamic> json) {
    final list = json['badges'];
    if (list is List) {
      return list
          .map((e) => Badge.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (json['badge'] != null) {
      return [Badge.fromJson(json['badge'] as Map<String, dynamic>)];
    }
    return const [];
  }

  static int _toAmount(String type, dynamic value) {
    if (value == null) return 0;
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return 0;
    if (type.toUpperCase() == 'PERCENT') {
      return parsed.round();
    }
    return (parsed * 100).round();
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    final discountType = (json['discountType'] ?? 'FIXED_AMOUNT').toString();
    final start = json['startDate'] != null
        ? DateTime.tryParse(json['startDate'].toString())
        : null;
    final end = json['endDate'] != null
        ? DateTime.tryParse(json['endDate'].toString())
        : null;
    final now = DateTime.now();
    final rawId = json['id'];
    final parsedId = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    return Coupon(
      id: parsedId,
      title: json['title'] ??
          json['description'] ??
          json['code'] ??
          'Coupon ${json['id']}',
      code: json['code'] ?? '',
      discountType: discountType,
      discountValue: _toAmount(discountType, json['discountValue']),
      minSpend: json['minSpend'] as int?,
      maxDiscount: json['maxDiscount'] as int?,
      startDate: start,
      endDate: end,
      sourceId: json['sourceId']?.toString() ??
          (json['source'] != null ? '${json['source']['id']}' : null),
      imageUrl: json['imageUrl'],
      categories: _parseCategories(json),
      badges: _parseBadges(json),
      dealUrl: json['dealUrl'],
      trackingLink: json['dealUrl'],
      deeplink: json['deeplink'],
      isActive: json['isActive'] ??
          ((start == null || !start.isAfter(now)) &&
              (end == null || !end.isBefore(now))),
      priority: json['priority'] is int
          ? json['priority'] as int
          : int.tryParse('${json['priority']}'),
    );
  }

  bool get isPercent => discountType.toUpperCase() == 'PERCENT';

  DateTime? get expiredAt => endDate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue,
        'minSpend': minSpend,
        'maxDiscount': maxDiscount,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'sourceId': sourceId,
        'imageUrl': imageUrl,
        'categories': categories.map((c) => c.toJson()).toList(),
        'badges': badges.map((b) => b.toJson()).toList(),
        'dealUrl': dealUrl,
        'trackingLink': trackingLink,
        'deeplink': deeplink,
        'isActive': isActive,
        'priority': priority,
      };
}
