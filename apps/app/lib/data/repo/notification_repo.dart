import '../../core/result.dart';
import '../../models/app_notification.dart';

abstract class NotificationRepo {
  Future<PageResult<AppNotification>> list({
    int page,
    int pageSize,
    NotificationType? type,
  });
}

