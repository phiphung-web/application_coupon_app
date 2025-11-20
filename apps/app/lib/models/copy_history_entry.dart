class CopyHistoryEntry {
  final int couponId;
  final String code;
  final String title;
  final DateTime copiedAt;

  const CopyHistoryEntry({
    required this.couponId,
    required this.code,
    required this.title,
    required this.copiedAt,
  });

  factory CopyHistoryEntry.fromJson(Map<String, dynamic> json) => CopyHistoryEntry(
        couponId: json['couponId'] as int? ?? int.tryParse('${json['couponId']}') ?? 0,
        code: json['code'] ?? '',
        title: json['title'] ?? '',
        copiedAt: DateTime.tryParse(json['copiedAt']?.toString() ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'couponId': couponId,
        'code': code,
        'title': title,
        'copiedAt': copiedAt.toIso8601String(),
      };
}

