import 'package:flutter/material.dart';
import '../../data/impl/product_repo_mock.dart';
import '../../data/impl/coupon_repo_mock.dart';
import '../../models/product.dart';
import '../../models/coupon.dart';
import '../detail/product_detail_screen.dart';
import '../detail/voucher_detail_screen.dart';
import '../../widgets/product_grid_card.dart';
import '../../widgets/coupon_list_item.dart';

String _money(num v) {
  final s = v.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - 1 - i;
    buf.write(s[idx]);
    if ((i + 1) % 3 == 0 && idx != 0) buf.write('.');
  }
  return buf.toString().split('').reversed.join() + 'đ';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pRepo = ProductRepoMock();
  final _cRepo = CouponRepoMock();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 8),
        _banner(),
        const SizedBox(height: 16),

        _sectionTitle('Sản phẩm hot', trailing: TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HotProductsScreen())),
          child: const Text('Xem tất cả'),
        )),
        FutureBuilder<List<Product>>(
          future: _pRepo.hot(limit: 8),
          builder: (_, snap) {
            if (!snap.hasData) return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
            final items = snap.data!;
            return SizedBox(
              height: 260,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) => SizedBox(
                  width: 160,
                  child: ProductGridCard(product: items[i], onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: items[i].id)));
                  }),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: items.length,
              ),
            );
          },
        ),

        const SizedBox(height: 12),
        _sectionTitle('Mã hot', trailing: TextButton(
          onPressed: () {}, // TODO: điều hướng màn xem tất cả mã hot
          child: const Text('Xem tất cả'),
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
        _sectionTitle('Tất cả sản phẩm'),
        const SizedBox(height: 8),
        FutureBuilder<List<Product>>(
          future: _pRepo.list(page: 1, pageSize: 20),
          builder: (_, snap) {
            if (!snap.hasData) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
            final items = snap.data!;
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
    final _repo = ProductRepoMock();
    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm hot')),
      body: FutureBuilder<List<Product>>(
        future: _repo.hot(limit: 40),
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
