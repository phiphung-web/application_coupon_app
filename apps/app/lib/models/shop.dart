class Shop {
  /// ID dạng string theo JSON: "shopee", "lazada", ...
  final String id;
  final String name;
  final String? logoUrl;
  final String? domain;
  final int priority;     // mặc định 0 nếu không có
  final bool isActive;    // mặc định true nếu không có

  const Shop({
    required this.id,
    required this.name,
    this.logoUrl,
    this.domain,
    this.priority = 0,
    this.isActive = true,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    // id trong JSON là string; nếu lỡ là số thì toString()
    final id = json['id']?.toString() ?? '';
    return Shop(
      id: id,
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? json['logo_url'],
      domain: json['domain'],
      priority: (json['priority'] is num) ? (json['priority'] as num).toInt() : 0,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logoUrl': logoUrl,
        'domain': domain,
        'priority': priority,
        'isActive': isActive,
      };
}
