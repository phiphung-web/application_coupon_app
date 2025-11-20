import '../models/app_notification.dart';
import '../models/coupon.dart';
import '../models/product.dart';
import '../services/notification_service.dart';
import 'notification_prefs_service.dart';
import 'push_service.dart';

class NotificationScheduler {
  NotificationScheduler._();

  static final NotificationScheduler instance = NotificationScheduler._();

  final NotificationPrefsService _prefs = NotificationPrefsService.instance;
  final NotificationService _notifications = NotificationService.instance;

  Future<void> handleCoupons(List<Coupon> coupons) async {
    if (!await _prefs.isPersonalEnabled()) return;
    final enabledSources = await _prefs.sourceIds();
    for (final coupon in coupons) {
      final sourceId = coupon.sourceId;
      if (sourceId == null || !enabledSources.contains(sourceId)) continue;
      if (await _prefs.hasSeenCoupon(coupon.id)) continue;
      await _prefs.markCouponSeen(coupon.id);
      final notif = AppNotification(
        id: coupon.id,
        title: 'Nguồn ${coupon.sourceName ?? sourceId} có mã mới',
        message: coupon.title,
        type: NotificationType.personal,
        importance: 2,
        tags: const ['source'],
        createdAt: DateTime.now(),
        couponId: coupon.id,
        sourceId: int.tryParse(sourceId),
      );
      _notifications.addLocal(notif);
      await PushService.instance.show(
        title: notif.title,
        body: notif.message,
        id: coupon.id,
      );
    }
  }

  Future<void> handleProducts(List<Product> products) async {
    if (!await _prefs.isPersonalEnabled()) return;
    final items = await _prefs.itemIds();
    for (final product in products) {
      if (product.primaryCouponId == null) continue;
      if (!items.contains(product.id)) continue;
      final couponId = product.primaryCouponId!;
      if (await _prefs.hasSeenCoupon(couponId)) continue;
      await _prefs.markCouponSeen(couponId);
      final notif = AppNotification(
        id: couponId,
        title: '${product.name} vừa có mã mới',
        message: 'Sử dụng mã #$couponId để săn ưu đãi tốt nhất.',
        type: NotificationType.personal,
        importance: 3,
        tags: const ['item'],
        createdAt: DateTime.now(),
        itemId: product.id,
        couponId: couponId,
      );
      _notifications.addLocal(notif);
      await PushService.instance.show(
        title: notif.title,
        body: notif.message,
        id: couponId,
      );
    }
  }
}
