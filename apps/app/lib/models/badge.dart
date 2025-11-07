import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge.freezed.dart';
part 'badge.g.dart';

@freezed
class Badge with _$Badge {
  const factory Badge({
    required String key,
    required String label,
    String? color,
    String? bgColor,
    String? icon,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}
