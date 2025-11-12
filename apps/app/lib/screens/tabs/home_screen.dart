import 'package:flutter/material.dart';

import '../../core/result.dart';
import '../../data/impl/coupon_repo_remote.dart';
import '../../data/impl/product_repo_remote.dart';
import '../../data/repo/coupon_repo.dart';
import '../../data/repo/product_repo.dart';
import '../../models/coupon.dart';
import '../../models/product.dart';
import '../../widgets/coupon_list_item.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/product_grid_card.dart';
import '../../widgets/retry_view.dart';
import '../detail/product_detail_screen.dart';
import '../detail/voucher_detail_screen.dart';
import 'hot_coupons_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepo _productRepo = ProductRepoRemote();
  final CouponRepo _couponRepo = CouponRepoRemote();

  bool _fallbackNotified = false;
  int _hotProductsReloadKey = 0;
  int _hotCouponsReloadKey = 0;
  int _allProductsReloadKey = 0;

  void _showFallbackBanner(BuildContext context) {
    if (_fallbackNotified) return;
    _fallbackNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot reach server, showing cached/demo data for now.',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 8),
        _buildBanner(),
        const SizedBox(height: 16),
        _sectionTitle(
          'Hot products',
          trailing: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HotProductsScreen(),
              ),
            ),
            child: const Text('View all'),
          ),
        ),
        _buildHotProductsSection(),
        const SizedBox(height: 12),
        _sectionTitle(
          'Hot coupons',
          trailing: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HotCouponsScreen(),
                ),
              );
            },
            child: const Text('View all'),
          ),
        ),
        _buildHotCouponsSection(),
        const SizedBox(height: 12),
        _sectionTitle('All products'),
        const SizedBox(height: 8),
        _buildAllProductsSection(),
      ],
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 140,
      child: PageView(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://picsum.photos/seed/home_banner_$i/1200/400',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotProductsSection() {
    return FutureBuilder<List<Product>>(
      key: ValueKey(_hotProductsReloadKey),
      future: _productRepo.hot(limit: 8),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 260,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, __) =>
                  const LoadingSkeleton(width: 160, height: 220),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: 4,
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: RetryView(
              message: 'Failed to load hot products.',
              onRetry: () =>
                  setState(() => _hotProductsReloadKey = _hotProductsReloadKey + 1),
            ),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No highlighted products at the moment.'),
          );
        }
        return SizedBox(
          height: 260,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => SizedBox(
              width: 160,
              child: ProductGridCard(
                product: items[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: items[i].id),
                  ),
                ),
              ),
            ),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: items.length,
          ),
        );
      },
    );
  }

  Widget _buildHotCouponsSection() {
    return FutureBuilder<List<Coupon>>(
      key: ValueKey(_hotCouponsReloadKey),
      future: _couponRepo.hot(limit: 10),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 132,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, __) =>
                  const LoadingSkeleton(width: 320, height: 120),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: 3,
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: RetryView(
              message: 'Failed to load hot coupons.',
              onRetry: () =>
                  setState(() => _hotCouponsReloadKey = _hotCouponsReloadKey + 1),
            ),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No hot coupons right now.'),
          );
        }
        return SizedBox(
          height: 132,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => SizedBox(
              width: 320,
              child: CouponListItem(
                coupon: items[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VoucherDetailScreen(couponId: items[i].id),
                  ),
                ),
              ),
            ),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: items.length,
          ),
        );
      },
    );
  }

  Widget _buildAllProductsSection() {
    return FutureBuilder<PageResult<Product>>(
      key: ValueKey(_allProductsReloadKey),
      future: _productRepo.list(page: 1, pageSize: 20),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: RetryView(
              message: 'Failed to load product list.',
              onRetry: _retryAllProducts,
            ),
          );
        }
        final result = snapshot.data;
        if (result == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No products available.'),
          );
        }
        if (result.fromFallback) {
          _showFallbackBanner(context);
        }
        final items = result.data;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .62,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => ProductGridCard(
              product: items[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: items[i].id),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _retryAllProducts() async {
    setState(() => _allProductsReloadKey++);
  }

  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

class HotProductsScreen extends StatelessWidget {
  const HotProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductRepo repo = ProductRepoRemote();
    return Scaffold(
      appBar: AppBar(title: const Text('Hot products')),
      body: FutureBuilder<List<Product>>(
        future: repo.hot(limit: 40),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .62,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => ProductGridCard(
                product: items[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: items[i].id),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
