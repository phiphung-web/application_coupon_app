class Shop {
  final String id;
  final String name;
  final String type;
  final String? description;
  final String? logoUrl;
  final String? websiteUrl;
  final int priority;
  final bool isActive;
  final int? couponCount;
  final int? itemCount;

  const Shop({
    required this.id,
    required this.name,
    this.type = 'ECOM',
    this.description,
    this.logoUrl,
    this.websiteUrl,
    this.priority = 0,
    this.isActive = true,
    this.couponCount,
    this.itemCount,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    return Shop(
      id: id,
      name: json['name'] ?? '',
      type: json['type'] ?? 'ECOM',
      description: json['description'],
      logoUrl: json['imageUrl'] ?? json['logoUrl'],
      websiteUrl: json['websiteUrl'] ?? json['domain'],
      priority: json['priority'] is num
          ? (json['priority'] as num).toInt()
          : int.tryParse('${json['priority']}') ?? 0,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      couponCount: json['couponCount'] is int
          ? json['couponCount'] as int
          : int.tryParse('${json['couponCount']}'),
      itemCount: json['itemCount'] is int
          ? json['itemCount'] as int
          : int.tryParse('${json['itemCount']}'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'description': description,
        'imageUrl': logoUrl,
        'websiteUrl': websiteUrl,
        'priority': priority,
        'isActive': isActive,
        'couponCount': couponCount,
        'itemCount': itemCount,
      };
}
