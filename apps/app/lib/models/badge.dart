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

  factory Badge.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? json['label'] ?? '';
    final slug = json['slug'] ?? json['key'] ?? name;
    return Badge(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      key: slug.toString(),
      label: name.toString(),
      color: json['color'] ?? json['colorCode'],
      bgColor: json['bgColor'] ?? json['colorCode'],
      icon: json['icon'] ?? json['iconUrl'],
      priority: json['priority'] is int
          ? json['priority'] as int
          : int.tryParse('${json['priority']}') ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

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
