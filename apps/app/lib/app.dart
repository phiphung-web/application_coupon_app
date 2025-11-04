import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/shell.dart';

class CouponApp extends StatelessWidget {
  const CouponApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coupon App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
