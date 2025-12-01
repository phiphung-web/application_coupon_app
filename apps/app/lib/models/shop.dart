class Shop {
  final String id;
  final String name;
  final String type;
  final String? description;
  final String? logoUrl;
  final String? websiteUrl;
  final int priority;
  final bool isActive;

  const Shop({
    required this.id,
    required this.name,
    this.type = 'ECOM',
    this.description,
    this.logoUrl,
    this.websiteUrl,
    this.priority = 0,
    this.isActive = true,
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
      };
}
