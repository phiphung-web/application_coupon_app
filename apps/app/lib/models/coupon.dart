class Coupon {
  final String id;
  final String title;
  final String code;
  final String discountType; // PERCENT | FIXED
  final double discountValue;
  final double? minSpend;
  final double? maxDiscount;
  final DateTime? expiredAt;
  final int? categoryId;
  final String? shopId;
  final String? imageUrl;
  final List<String>? tags;
  final int? priority;
  final String? trackingLink;
  final String? deeplink;
  final bool isActive;

  Coupon({
    required this.id,
    required this.title,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minSpend,
    this.maxDiscount,
    this.expiredAt,
    this.categoryId,
    this.shopId,
    this.imageUrl,
    this.tags,
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
    discountValue: (json['discountValue'] ?? 0).toDouble(),
    minSpend: json['minSpend']?.toDouble(),
    maxDiscount: json['maxDiscount']?.toDouble(),
    expiredAt: json['expiredAt'] != null
        ? DateTime.tryParse(json['expiredAt'])
        : null,
    categoryId: json['categoryId'],
    shopId: json['shopId'],
    imageUrl: json['imageUrl'],
    tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
    priority: json['priority'],
    trackingLink: json['trackingLink'],
    deeplink: json['deeplink'],
    isActive: json['isActive'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'code': code,
    'discountType': discountType,
    'discountValue': discountValue,
    'minSpend': minSpend,
    'maxDiscount': maxDiscount,
    'expiredAt': expiredAt?.toIso8601String(),
    'categoryId': categoryId,
    'shopId': shopId,
    'imageUrl': imageUrl,
    'tags': tags,
    'priority': priority,
    'trackingLink': trackingLink,
    'deeplink': deeplink,
    'isActive': isActive,
  };
}
