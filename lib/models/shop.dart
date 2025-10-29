class Shop {
  final String id;
  final String name;
  final String logoUrl;
  final String domain;
  final int priority;
  final bool isActive;

  Shop({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.domain,
    required this.priority,
    required this.isActive,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        id: json["id"],
        name: json["name"],
        logoUrl: json["logoUrl"],
        domain: json["domain"],
        priority: json["priority"] ?? 0,
        isActive: json["isActive"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "logoUrl": logoUrl,
        "domain": domain,
        "priority": priority,
        "isActive": isActive,
      };
}
