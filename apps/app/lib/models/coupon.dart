class Coupon {
  final String id;
  final String shopId;
  final List<String> categoryIds;
  final String title;
  final String code;
  final String type;
  final num value;
  final int? maxDiscount;
  final int? minSpend;
  final String? terms;
  final int? quotaTotal;
  final int? quotaUsed;
  final DateTime startAt;
  final DateTime endAt;
  final String? deeplink;
  final String? trackingLink;
  final String? imageUrl;
  final List<String> tags;
  final int? priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Coupon({
    required this.id,
    required this.shopId,
    required this.categoryIds,
    required this.title,
    required this.code,
    required this.type,
    required this.value,
    this.maxDiscount,
    this.minSpend,
    this.terms,
    this.quotaTotal,
    this.quotaUsed,
    required this.startAt,
    required this.endAt,
    this.deeplink,
    this.trackingLink,
    this.imageUrl,
    this.tags = const [],
    this.priority,
    this.status = "active",
    required this.createdAt,
    required this.updatedAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    id: json["id"],
    shopId: json["shopId"],
    categoryIds: (json["categoryIds"] as List)
        .map((e) => e.toString())
        .toList(),
    title: json["title"],
    code: json["code"],
    type: json["type"],
    value: json["value"],
    maxDiscount: json["maxDiscount"],
    minSpend: json["minSpend"],
    terms: json["terms"],
    quotaTotal: json["quotaTotal"],
    quotaUsed: json["quotaUsed"],
    startAt: DateTime.parse(json["startAt"]).toUtc(),
    endAt: DateTime.parse(json["endAt"]).toUtc(),
    deeplink: json["deeplink"],
    trackingLink: json["trackingLink"],
    imageUrl: json["imageUrl"],
    tags:
        (json["tags"] as List?)?.map((e) => e.toString()).toList() ?? const [],
    priority: json["priority"],
    status: json["status"] ?? "active",
    createdAt: DateTime.parse(json["createdAt"]).toUtc(),
    updatedAt: DateTime.parse(json["updatedAt"]).toUtc(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "shopId": shopId,
    "categoryIds": categoryIds,
    "title": title,
    "code": code,
    "type": type,
    "value": value,
    "maxDiscount": maxDiscount,
    "minSpend": minSpend,
    "terms": terms,
    "quotaTotal": quotaTotal,
    "quotaUsed": quotaUsed,
    "startAt": startAt.toIso8601String(),
    "endAt": endAt.toIso8601String(),
    "deeplink": deeplink,
    "trackingLink": trackingLink,
    "imageUrl": imageUrl,
    "tags": tags,
    "priority": priority,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
