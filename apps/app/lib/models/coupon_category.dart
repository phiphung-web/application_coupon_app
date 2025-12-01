class CouponCategory {
  final int id;
  final String name;
  final String? description;
  final int? couponCount;

  const CouponCategory({
    required this.id,
    required this.name,
    this.description,
    this.couponCount,
  });

  factory CouponCategory.fromJson(Map<String, dynamic> json) => CouponCategory(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        name: json['name'] ?? '',
        description: json['description'],
        couponCount: json['couponCount'] is int
            ? json['couponCount'] as int
            : int.tryParse('${json['couponCount']}'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'couponCount': couponCount,
      };
}
