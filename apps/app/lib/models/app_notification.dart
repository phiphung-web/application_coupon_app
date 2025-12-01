enum NotificationType { system, event, personal }

NotificationType notificationTypeFrom(String? raw) {
  switch (raw?.toUpperCase()) {
    case 'EVENT':
      return NotificationType.event;
    case 'PERSONAL':
      return NotificationType.personal;
    default:
      return NotificationType.system;
  }
}

class AppNotification {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final int importance;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int? sourceId;
  final int? itemId;
  final int? couponId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.importance,
    required this.tags,
    required this.createdAt,
    this.expiresAt,
    this.sourceId,
    this.itemId,
    this.couponId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        type: notificationTypeFrom(json['category']?.toString()),
        importance: json['importance'] is num ? (json['importance'] as num).toInt() : 0,
        tags: (json['tags'] as List?)?.whereType<String>().toList() ?? const [],
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        expiresAt: json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'].toString())
            : null,
        sourceId: json['sourceId'] as int?,
        itemId: json['itemId'] as int?,
        couponId: json['couponId'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'category': type.name.toUpperCase(),
        'importance': importance,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'sourceId': sourceId,
        'itemId': itemId,
        'couponId': couponId,
      };
}

