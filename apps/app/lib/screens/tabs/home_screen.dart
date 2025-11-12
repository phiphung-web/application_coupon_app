import 'package:flutter/material.dart';
import '../../data/impl/product_repo_remote.dart';
import '../../data/impl/coupon_repo_remote.dart';
import '../../core/result.dart';
import '../../data/repo/product_repo.dart';
import '../../data/repo/coupon_repo.dart';
import '../../models/product.dart';
import '../../models/coupon.dart';
import '../detail/product_detail_screen.dart';
import '../detail/voucher_detail_screen.dart';
import '../../widgets/product_grid_card.dart';
import '../../widgets/coupon_list_item.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/retry_view.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepo _pRepo = ProductRepoRemote();
  final CouponRepo _cRepo = CouponRepoRemote();
  bool _fallbackNotified = false;
  int _hotProductsRequestId = 0;
  int _hotCouponsRequestId = 0;

  void _showFallbackBanner(BuildContext context) {
    if (_fallbackNotified) return;
    _fallbackNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không kết nối được server, đang tạm hiển thị dữ liệu demo.'),
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
        _banner(),
        const SizedBox(height: 16),


_sectionTitle('San pham hot', trailing: TextButton(
  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HotProductsScreen())),
  child: const Text('Xem tat ca'),
)),
FutureBuilder<List<Product>>(
  key: ValueKey(_hotProductsRequestId),
  future: _pRepo.hot(limit: 8),
  builder: (_, snap) {
    if (snap.connectionState == ConnectionState.waiting) {
      return SizedBox(
        height: 260,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, __) => const LoadingSkeleton(width: 160, height: 220),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemCount: 4,
        ),
      );
    }
    if (snap.hasError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: RetryView(
          message: 'Khong tai duoc danh sach san pham hot.',
          onRetry: () => setState(() => _hotProductsRequestId++),
        ),
      );
    }
    final items = snap.data or []
    if not items:
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Chua co san pham noi bat.'),
      )
    return SizedBox(
      height: 260,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => SizedBox(
          width: 160,
          child: ProductGridCard(product: items[i], onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: items[i].id)))
          }),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: len(items),
      ),
    )
  },
),

        const SizedBox(height: 12),
        _sectionTitle('MÃ£ hot', trailing: TextButton(
          onPressed: () {}, // TODO: Ä‘iá»u hÆ°á»›ng mÃ n xem táº¥t cáº£ mÃ£ hot
          child: const Text('Xem táº¥t cáº£'),
        )),
        FutureBuilder<List<Coupon>>(
          future: _cRepo.hot(limit: 10),
          builder: (_, snap) {
            if (!snap.hasData) return const SizedBox(height: 132, child: Center(child: CircularProgressIndicator()));
            final items = snap.data!;
            return SizedBox(
              height: 132,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) => SizedBox(
                  width: 320,
                  child: CouponListItem(coupon: items[i], onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => VoucherDetailScreen(couponId: items[i].id)));
                  }),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: items.length,
              ),
            );
          },
        ),

        const SizedBox(height: 12),
        _sectionTitle('Táº¥t cáº£ sáº£n pháº©m'),
        const SizedBox(height: 8),
        FutureBuilder<PageResult<Product>>(
          future: _pRepo.list(page: 1, pageSize: 20),
          builder: (_, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final result = snap.data!;
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
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .62,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => ProductGridCard(product: items[i], onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: items[i].id)));
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _banner() {
    return SizedBox(
      height: 140,
      child: PageView(
        children: List.generate(3, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network('https://picsum.photos/seed/b$i/1200/400', fit: BoxFit.cover),
          ),
        )),
      ),
    );
  }

  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
        if (trailing != null) trailing,
      ]),
    );
  }
}

class HotProductsScreen extends StatelessWidget {
  const HotProductsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ProductRepo repo = ProductRepoRemote();
    return Scaffold(
      appBar: AppBar(title: const Text('Sáº£n pháº©m hot')),
      body: FutureBuilder<List<Product>>(
        future: repo.hot(limit: 40),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .62,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => ProductGridCard(product: items[i], onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: items[i].id)));
              }),
            ),
          );
        },
      ),
    );
  }
}
