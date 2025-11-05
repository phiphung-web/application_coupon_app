class Coupon {
  final String id;
  final String code;
  final String title;

  /// Loại giảm: 'PERCENT' hoặc 'FIXED'
  final String discountType;

  /// Giá trị giảm (VD: 10 = 10% hoặc 50000đ)
  final int discountValue;

  /// Giảm tối đa (dành cho loại PERCENT)
  final int? maxDiscount;

  /// Giá trị đơn hàng tối thiểu để áp dụng (nếu có)
  final int? minSpend;

  /// Danh mục áp dụng (0 = tất cả)
  final int? categoryId;

  /// Các loại sản phẩm có thể áp dụng (VD: ['Shoes', 'Gadget'])
  final List<String>? applicableTypes;

  /// Ngày hết hạn
  final DateTime? expiredAt;

  /// Độ ưu tiên / độ hot
  final int? priority;

  /// Nhãn, tag (VD: ['hot', 'exclusive'])
  final List<String> tags;

  /// Shop áp dụng (VD: 'shopee', 'tiki')
  final String? shopId;

  /// Hình ảnh minh họa
  final String? imageUrl;

  /// Link tới sản phẩm / deeplink
  final String? deeplink;

  /// Link tracking (nếu có)
  final String? trackingLink;

  const Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    this.maxDiscount,
    this.minSpend,
    this.categoryId,
    this.applicableTypes,
    this.expiredAt,
    this.priority,
    this.tags = const [],
    this.shopId,
    this.imageUrl,
    this.deeplink,
    this.trackingLink,
  });

  /// Fake từ JSON nếu có dữ liệu
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'].toString(),
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      discountType: json['discountType'] ?? 'PERCENT',
      discountValue: json['discountValue'] ?? 0,
      maxDiscount: json['maxDiscount'],
      minSpend: json['minSpend'],
      categoryId: json['categoryId'],
      applicableTypes: json['applicableTypes'] == null
          ? []
          : List<String>.from(json['applicableTypes']),
      expiredAt: json['expiredAt'] != null
          ? DateTime.tryParse(json['expiredAt'])
          : null,
      priority: json['priority'],
      tags: json['tags'] == null ? [] : List<String>.from(json['tags']),
      shopId: json['shopId'],
      imageUrl: json['imageUrl'],
      deeplink: json['deeplink'],
      trackingLink: json['trackingLink'],
    );
  }
}
