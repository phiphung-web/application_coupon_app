import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../core/layout/responsive.dart';
import 'tabs/home_screen.dart';
import 'tabs/products_screen.dart';
import 'tabs/coupons_screen.dart';
import 'tabs/account_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomeScreen(),
      ProductsScreen(),
      CouponsScreen(),
      AccountScreen(),
    ];
    return Scaffold(
      appBar: const AppHeader(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IndexedStack(index: index, children: pages),
          ),
        ),
      ),
      bottomNavigationBar: Responsive(
        mobile: BottomNav(
          index: index,
          onTap: (i) => setState(() => index = i),
        ),
        desktop: const SizedBox.shrink(),
      ),
    );
  }
}
