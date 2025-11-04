class Product {
  final int id;
  final String name;
  final String imageUrl;
  final int basePrice;       // giá gốc
  final int categoryId;
  final String type;         // dùng đối sánh với coupon.applicableTypes
  final int shopId;
  final String source;       // ví dụ: 'Shopee', 'Lazada'...

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.basePrice,
    required this.categoryId,
    required this.type,
    required this.shopId,
    required this.source,
  });
}
