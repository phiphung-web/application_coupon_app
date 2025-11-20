import 'dart:async';

import '../core/result.dart';
import '../data/impl/notification_repo_remote.dart';
import '../data/repo/notification_repo.dart';
import '../models/app_notification.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final NotificationRepo _repo = NotificationRepoRemote();
  final _controller = StreamController<List<AppNotification>>.broadcast();
  List<AppNotification> _cache = const [];

  Stream<List<AppNotification>> stream() => _controller.stream;

  List<AppNotification> get current => _cache;

  Future<PageResult<AppNotification>> fetch({
    int page = 1,
    int pageSize = 30,
    NotificationType? filter,
  }) async {
    final res = await _repo.list(page: page, pageSize: pageSize, type: filter);
    if (page == 1) {
      _cache = res.data;
      _controller.add(_cache);
    } else {
      _cache = [..._cache, ...res.data];
      _controller.add(_cache);
    }
    return res;
  }

  void addLocal(AppNotification notification) {
    _cache = [notification, ..._cache];
    _controller.add(_cache);
  }

  void dispose() {
    _controller.close();
  }
}

