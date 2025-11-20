import 'package:flutter/material.dart';

import '../core/layout/responsive.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav.dart';
import 'detail/product_detail_screen.dart';
import 'detail/voucher_detail_screen.dart';
import 'tabs/account_screen.dart';
import 'tabs/explore_screen.dart';
import 'tabs/home_screen.dart';
import 'tabs/notifications_screen.dart';

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
  final ValueNotifier<int> _homeReload = ValueNotifier<int>(0);

  final _navKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onTabSelected(int i) {
    if (_index == i) {
      if (i == 0) {
        _homeReload.value++;
      } else {
        final nav = _navKeys[i].currentState;
        nav?.popUntil((route) => route.isFirst);
      }
    } else {
      setState(() => _index = i);
    }
  }

  @override
  void dispose() {
    _homeReload.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
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
                  _TabNavigator(
                    navigatorKey: _navKeys[0],
                    child: HomeScreen(reloadTrigger: _homeReload),
                  ),
                  _TabNavigator(
                    navigatorKey: _navKeys[1],
                    child: const ExploreScreen(),
                  ),
                  _TabNavigator(
                    navigatorKey: _navKeys[2],
                    child: const NotificationsScreen(),
                  ),
                  _TabNavigator(
                    navigatorKey: _navKeys[3],
                    child: const AccountScreen(),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Responsive(
          mobile: BottomNav(
            index: _index,
            onTap: _onTabSelected,
          ),
          desktop: const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  const _TabNavigator({
    required this.child,
    required this.navigatorKey,
  });

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.product:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: id),
          settings: settings,
        );
      case AppRoutes.coupon:
        final id = settings.arguments as int;
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
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
