import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushService {
  PushService._();

  static final PushService instance = PushService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(initSettings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> show({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'coupons_hot_channel',
      'Thông báo ưu đãi',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }
}

