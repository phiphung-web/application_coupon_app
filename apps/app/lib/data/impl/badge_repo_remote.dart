import 'package:flutter/foundation.dart' show debugPrint;

import '../../models/badge.dart';
import '../repo/badge_repo.dart';
import '../../services/api_client.dart';
import 'badge_repo_mock.dart';

class BadgeRepoRemote implements BadgeRepo {
  BadgeRepoRemote({
    ApiClient? apiClient,
    BadgeRepo? fallback,
  })  : _api = apiClient ?? ApiClient(),
        _fallback = fallback ?? BadgeRepoMock();

  final ApiClient _api;
  final BadgeRepo _fallback;

  @override
  Future<List<Badge>> list({bool activeOnly = true}) async {
    try {
      final query = activeOnly ? {'active': 'true'} : null;
      final json = await _api.get('badges', query: query);
      final List<dynamic> items;
      if (json is List) {
        items = json;
      } else if (json is Map && json['items'] is List) {
        items = json['items'] as List<dynamic>;
      } else {
        items = const [];
      }
      return items
          .map((e) => Badge.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('BadgeRepoRemote.list fallback: $e');
      return _fallback.list(activeOnly: activeOnly);
    }
  }
}
