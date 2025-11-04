import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 16),
        ListTile(leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('User'), subtitle: Text('Thống kê cá nhân hiển thị tại đây')),
        Divider(),
        ListTile(leading: Icon(Icons.history), title: Text('Lịch sử sử dụng mã')),
        ListTile(leading: Icon(Icons.bar_chart), title: Text('Thống kê')),
        ListTile(leading: Icon(Icons.settings), title: Text('Cài đặt')),
      ],
    );
  }
}
