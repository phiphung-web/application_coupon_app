import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import '../core/layout/responsive.dart';

import 'tabs/home_screen.dart';
import 'tabs/products_screen.dart';
import 'tabs/coupons_screen.dart';
import 'tabs/account_screen.dart';
import 'detail/product_detail_screen.dart';
import 'detail/voucher_detail_screen.dart';

/// Định nghĩa route đặt dùng chung
class AppRoutes {
  static const product = '/product';
  static const coupon = '/coupon';
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // Navigator riêng cho từng tab
  final _navKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        final nav = _navKeys[_index].currentState!;
        if (nav.canPop()) {
          nav.pop();
        } else {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        appBar: const AppHeader(),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IndexedStack(
                index: _index,
                children: [
                  _TabNavigator(key: _navKeys[0], child: const HomeScreen()),
                  _TabNavigator(
                    key: _navKeys[1],
                    child: const ProductsScreen(),
                  ),
                  _TabNavigator(key: _navKeys[2], child: const CouponsScreen()),
                  _TabNavigator(key: _navKeys[3], child: const AccountScreen()),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Responsive(
          mobile: BottomNav(
            index: _index,
            onTap: (i) => setState(() => _index = i),
          ),
          desktop: const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Mỗi tab có 1 Navigator riêng để push màn chi tiết
class _TabNavigator extends StatelessWidget {
  final Widget child;
  const _TabNavigator({super.key, required this.child});

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.product:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: id),
          settings: settings,
        );
      case AppRoutes.coupon:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VoucherDetailScreen(couponId: id),
          settings: settings,
        );
      default:
        return MaterialPageRoute(builder: (_) => child, settings: settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: _onGenerateRoute);
  }
}
