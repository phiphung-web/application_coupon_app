import 'package:flutter/material.dart';

import 'coupons_screen.dart';
import 'products_screen.dart';
import 'sources_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Item'),
              Tab(text: 'Mã giảm giá'),
              Tab(text: 'Nguồn'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: const [
                ProductsScreen(),
                CouponsScreen(),
                SourcesScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
