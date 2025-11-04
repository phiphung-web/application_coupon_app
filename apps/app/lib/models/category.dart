class Category {
  final String id;
  final String name;
  final String slug;
  final String? iconUrl;
  final String? parentId;
  final int order;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
    this.parentId,
    this.order = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        iconUrl: json["iconUrl"],
        parentId: json["parentId"],
        order: json["order"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "iconUrl": iconUrl,
        "parentId": parentId,
        "order": order,
      };
}
