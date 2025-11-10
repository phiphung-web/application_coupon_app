class Shop {
  final String id;
  final String name;
  final String type; // ECOM | APP | GAME | SERVICE | OTHER
  final String? logoUrl;
  final String? domain;
  final String? packageId;
  final String? bundleId;
  final String? publisher;
  final int priority;
  final bool isActive;

  const Shop({
    required this.id,
    required this.name,
    this.type = 'ECOM',
    this.logoUrl,
    this.domain,
    this.packageId,
    this.bundleId,
    this.publisher,
    this.priority = 0,
    this.isActive = true,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    return Shop(
      id: id,
      name: json['name'] ?? '',
      type: json['type'] ?? 'ECOM',
      logoUrl: json['logoUrl'] ?? json['logo_url'],
      domain: json['domain'],
      packageId: json['packageId'],
      bundleId: json['bundleId'],
      publisher: json['publisher'],
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
        'logoUrl': logoUrl,
        'domain': domain,
        'packageId': packageId,
        'bundleId': bundleId,
        'publisher': publisher,
        'priority': priority,
        'isActive': isActive,
      };
}
