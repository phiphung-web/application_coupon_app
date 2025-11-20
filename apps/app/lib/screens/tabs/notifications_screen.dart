import 'package:flutter/material.dart';

import '../../models/app_notification.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService.instance;
  NotificationType? _filter;
  bool _loading = true;
  List<AppNotification> _items = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _load();
    if (!mounted) return;
    _service.stream().listen((value) {
      if (mounted) {
        setState(() => _items = value);
      }
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _service.fetch(page: 1, pageSize: 40, filter: _filter);
    if (!mounted) return;
    setState(() {
      _items = _service.current;
      _loading = false;
    });
  }

  void _selectFilter(NotificationType? type) {
    setState(() => _filter = type);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDay(_items);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Thông báo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          _buildFilterBar(),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (groups.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text('Bạn chưa có thông báo nào trong 30 ngày.'),
            )
          else
            ...groups.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...entry.value.map(_NotificationTile.new),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final options = <(NotificationType?, String, IconData)>[
      (null, 'Tất cả', Icons.all_inclusive),
      (NotificationType.system, 'Hệ thống', Icons.shield_moon_outlined),
      (NotificationType.event, 'Sự kiện', Icons.bolt),
      (NotificationType.personal, 'Cá nhân', Icons.favorite),
    ];
    return Wrap(
      spacing: 10,
      children: options
          .map(
            (opt) => ChoiceChip(
              selected: _filter == opt.$1,
              onSelected: (_) => _selectFilter(opt.$1),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(opt.$3, size: 16),
                  const SizedBox(width: 4),
                  Text(opt.$2),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Map<String, List<AppNotification>> _groupByDay(
    List<AppNotification> notifications,
  ) {
    final map = <String, List<AppNotification>>{};
    for (final notif in notifications) {
      final key =
          '${notif.createdAt.day.toString().padLeft(2, '0')}/${notif.createdAt.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(notif);
    }
    return map;
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _NotificationTile(this.notification);

  @override
  Widget build(BuildContext context) {
    final color = switch (notification.type) {
      NotificationType.system => Colors.blueGrey,
      NotificationType.event => Colors.orange,
      NotificationType.personal => Colors.pink,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.1),
          child: Icon(_iconFor(notification.type), color: color),
        ),
        title: Text(notification.title),
        subtitle: Text(notification.message),
        trailing: Text(
          '${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
    );
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.system:
        return Icons.shield_outlined;
      case NotificationType.event:
        return Icons.local_fire_department;
      case NotificationType.personal:
        return Icons.favorite;
    }
  }
}

