class CouponCategory {
  final int id;
  final String name;
  final String? imageUrl;
  final int? parentId;
  final int priority;
  final bool isActive;

  const CouponCategory({
    required this.id,
    required this.name,
    this.imageUrl,
    this.parentId,
    this.priority = 0,
    this.isActive = true,
  });

  factory CouponCategory.fromJson(Map<String, dynamic> json) =>
      CouponCategory(
        id: json['id'] as int,
        name: json['name'] ?? '',
        imageUrl: json['imageUrl'],
        parentId: json['parentId'] as int?,
        priority: json['priority'] is int
            ? json['priority'] as int
            : int.tryParse('${json['priority']}') ?? 0,
        isActive: json['isActive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'parentId': parentId,
        'priority': priority,
        'isActive': isActive,
      };
}
