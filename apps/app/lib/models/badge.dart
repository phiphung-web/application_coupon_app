class Badge {
  final int id;
  final String key;
  final String label;
  final String? color;
  final String? bgColor;
  final String? icon;
  final int priority;
  final bool isActive;

  const Badge({
    required this.id,
    required this.key,
    required this.label,
    this.color,
    this.bgColor,
    this.icon,
    this.priority = 0,
    this.isActive = true,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
        id: json['id'] as int,
        key: json['key'] ?? '',
        label: json['label'] ?? '',
        color: json['color'],
        bgColor: json['bgColor'],
        icon: json['icon'],
        priority: json['priority'] is int
            ? json['priority'] as int
            : int.tryParse('${json['priority']}') ?? 0,
        isActive: json['isActive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'label': label,
        'color': color,
        'bgColor': bgColor,
        'icon': icon,
        'priority': priority,
        'isActive': isActive,
      };
}
