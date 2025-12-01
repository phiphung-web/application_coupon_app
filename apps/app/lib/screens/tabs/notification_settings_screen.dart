import 'package:flutter/material.dart';

import '../../services/notification_prefs_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationPrefsService _prefs = NotificationPrefsService.instance;

  bool _system = true;
  bool _event = true;
  bool _personal = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final system = await _prefs.isSystemEnabled();
    final event = await _prefs.isEventEnabled();
    final personal = await _prefs.isPersonalEnabled();
    if (!mounted) return;
    setState(() {
      _system = system;
      _event = event;
      _personal = personal;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thông báo')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Thông báo hệ thống'),
                  subtitle: const Text('Bảo trì, cập nhật phiên bản, điều khoản'),
                  value: _system,
                  onChanged: (value) {
                    setState(() => _system = value);
                    _prefs.setSystemEnabled(value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Thông báo sự kiện'),
                  subtitle: const Text('Flash sale, deal hot, khuyến mãi mùa lễ'),
                  value: _event,
                  onChanged: (value) {
                    setState(() => _event = value);
                    _prefs.setEventEnabled(value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Thông báo cá nhân hóa'),
                  subtitle: const Text('Nguồn theo dõi, item yêu thích có mã mới'),
                  value: _personal,
                  onChanged: (value) {
                    setState(() => _personal = value);
                    _prefs.setPersonalEnabled(value);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Bạn có thể quản lý bật/tắt theo từng item và nguồn ngay trong danh sách yêu thích.',
                  ),
                ),
              ],
            ),
    );
  }
}

