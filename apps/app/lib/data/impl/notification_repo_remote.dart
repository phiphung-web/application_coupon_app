import 'package:flutter/foundation.dart' show debugPrint;

import '../../core/result.dart';
import '../../models/app_notification.dart';
import '../repo/notification_repo.dart';
import '../../services/api_client.dart';

class NotificationRepoRemote implements NotificationRepo {
  NotificationRepoRemote({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  @override
  Future<PageResult<AppNotification>> list({
    int page = 1,
    int pageSize = 20,
    NotificationType? type,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': pageSize,
      if (type != null) 'category': type.name.toUpperCase(),
    };
    try {
      final json = await _api.get('notifications', query: query);
      final List items = json is List
          ? json
          : (json is Map<String, dynamic> ? (json['items'] as List? ?? const []) : const []);
      final data = items
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final meta = json is Map<String, dynamic> ? json['meta'] as Map<String, dynamic>? : null;
      final current = meta?['page'] as int? ?? page;
      final limit = meta?['limit'] as int? ?? pageSize;
      final total = meta?['total'] as int? ?? data.length;
      final hasMore = current * limit < total;
      return PageResult(
        data: data,
        hasMore: hasMore,
        nextPage: hasMore ? current + 1 : current,
        meta: meta,
      );
    } catch (e) {
      debugPrint('NotificationRepoRemote.list error: $e');
      return const PageResult(
        data: [],
        hasMore: false,
        nextPage: 1,
      );
    }
  }
}

