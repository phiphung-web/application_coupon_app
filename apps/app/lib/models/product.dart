class Product {
  final int id;
  final String name;
  final String imageUrl;

  /// Giá gốc
  final int basePrice;

  /// Giá sau khuyến mãi (nếu có). Nếu null => không giảm.
  final int? finalPrice;

  /// Phân loại / dùng để match coupon
  final int categoryId;
  final String type;

  /// Thông tin shop hiển thị
  final String? shopId;   // nếu bạn dùng string id shop ở chỗ khác có thể đổi sang String?
  final String? shopName;

  /// Badge hiển thị “HOT”, “Top Pick”, …
  final String? badge;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.basePrice,
    this.finalPrice,
    required this.categoryId,
    required this.type,
    this.shopId,
    this.shopName,
    this.badge,
  });

  /// Phần trăm giảm giá hiển thị (0 nếu không giảm)
  int get discountPercent {
    final fp = finalPrice;
    if (fp == null || fp >= basePrice) return 0;
    final diff = basePrice - fp;
    final pct = (diff * 100) ~/ basePrice;
    return pct.clamp(0, 99);
  }
}
