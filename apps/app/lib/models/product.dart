import 'coupon.dart';

/// Mô hình sản phẩm thống nhất với backend (NestJS / TypeORM)
class Product {
  final int id;
  final String name;
  final String? imageUrl;

  /// Giá hiện tại (đã áp dụng giảm)
  final double basePrice;

  /// Giá gốc niêm yết
  final double? originalPrice;

  /// Phần trăm giảm (tính sẵn, ví dụ 20%)
  final double? discountPercent;

  /// Danh mục (id)
  final int categoryId;

  /// Shop ID (string)
  final String? shopId;

  /// Mô tả ngắn
  final String? description;

  /// Sản phẩm hot
  final bool isHot;

  /// Mã giảm tốt nhất (nếu có)
  final Coupon? bestCoupon;

  Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.categoryId,
    this.imageUrl,
    this.originalPrice,
    this.discountPercent,
    this.shopId,
    this.description,
    this.isHot = false,
    this.bestCoupon,
  });

  /// Factory parse từ JSON (backend API)
  factory Product.fromJson(Map<String, dynamic> json) {
    double? original = json['originalPrice']?.toDouble();
    double base = (json['basePrice'] ?? 0).toDouble();
    double? percent = json['discountPercent'] != null
        ? (json['discountPercent'] as num).toDouble()
        : (original != null && original > 0
              ? (100 - (base * 100 / original))
              : null);

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      basePrice: base,
      originalPrice: original,
      discountPercent: percent,
      categoryId: json['categoryId'] ?? 0,
      shopId: json['shopId'],
      description: json['description'],
      isHot: json['isHot'] ?? false,
      bestCoupon: json['bestCoupon'] != null
          ? Coupon.fromJson(json['bestCoupon'])
          : null,
    );
  }

  /// Tính giá cuối cùng nếu có mã
  double get finalPrice {
    if (bestCoupon == null) return basePrice;
    final c = bestCoupon!;
    if (c.discountType == 'PERCENT') {
      return basePrice * (1 - (c.discountValue / 100));
    } else {
      return basePrice - c.discountValue;
    }
  }

  /// Tính % giảm hiển thị
  double get displayDiscountPercent {
    if (discountPercent != null) return discountPercent!;
    if (originalPrice == null || originalPrice == 0) return 0;
    return (100 - (basePrice * 100 / originalPrice!)).clamp(0, 100);
  }

  /// Convert ra JSON (nếu cần POST)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'basePrice': basePrice,
    'originalPrice': originalPrice,
    'discountPercent': discountPercent,
    'categoryId': categoryId,
    'shopId': shopId,
    'description': description,
    'isHot': isHot,
    if (bestCoupon != null) 'bestCoupon': bestCoupon!.toJson(),
  };
}
