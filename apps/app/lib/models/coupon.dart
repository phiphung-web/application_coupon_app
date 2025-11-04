enum DiscountType { percent, fixed }

class Coupon {
  final int id;
  final String title;
  final String code;

  // Áp dụng & liên hệ sản phẩm
  final int? shopId;
  final int? categoryId; // danh mục chính
  final List<int> categoryIds; // nhiều danh mục (nếu có)
  final List<String> applicableTypes; // loại/mặt hàng áp dụng (Accessory,...)

  // Điều kiện & mức giảm
  final DiscountType discountType; // percent|fixed
  final int discountValue; // % hoặc số tiền
  final int? maxDiscount; // trần giảm
  final int? minOrder; // đơn tối thiểu

  // Thời gian & UI
  final DateTime endAt;
  final bool isHot;
  final int priority;
  final List<String> tags;

  // Media & link
  final String? imageUrl;
  final String? trackingLink;
  final String? deeplink;

  // Mô tả điều kiện
  final List<String> terms;

  const Coupon({
    required this.id,
    required this.title,
    required this.code,
    required this.endAt,
    required this.discountType,
    required this.discountValue,
    this.shopId,
    this.categoryId,
    this.categoryIds = const [],
    this.applicableTypes = const [],
    this.maxDiscount,
    this.minOrder,
    this.isHot = false,
    this.priority = 0,
    this.tags = const [],
    this.imageUrl,
    this.trackingLink,
    this.deeplink,
    this.terms = const [],
  });
}
