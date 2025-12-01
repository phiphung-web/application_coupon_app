import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../data/impl/product_repo_remote.dart';
import '../../data/impl/coupon_repo_remote.dart';
import '../../data/repo/product_repo.dart';
import '../../data/repo/coupon_repo.dart';
import '../../models/product.dart';
import '../../models/coupon.dart';
import '../detail/product_detail_screen.dart';
import '../detail/voucher_detail_screen.dart';
import '../../widgets/product_grid_card.dart';
import '../../widgets/coupon_list_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductRepo _pRepo = ProductRepoRemote();
  final CouponRepo _cRepo = CouponRepoRemote();
  final _ctrl = TextEditingController();

  List<Product> _products = [];
  List<Coupon> _coupons = [];
  bool _loading = false;
  bool _fallbackNotified = false;

  Future<void> _doSearch(String q) async {
    setState(() => _loading = true);
    final PageResult<Product> ps = await _pRepo.list(page: 1, pageSize: 50, q: q);
    final PageResult<Coupon> cs = await _cRepo.list(page: 1, pageSize: 50, q: q);
    setState(() {
      _products = ps.data;
      _coupons = cs.data;
      _loading = false;
    });
    _maybeNotifyFallback(ps.fromFallback || cs.fromFallback);
  }

  void _maybeNotifyFallback(bool fromFallback) {
    if (!fromFallback || _fallbackNotified) return;
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
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            hintText: 'Tìm sản phẩm hoặc mã...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: _doSearch,
        ),
        const SizedBox(height: 12),
        if (_loading) const Center(child: CircularProgressIndicator()),
        if (!_loading && _products.isEmpty && _coupons.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text('Nhập từ khóa để tìm kiếm'),
          ),
        if (_products.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Sản phẩm'),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .62,
            ),
            itemCount: _products.length,
            itemBuilder: (_, i) => ProductGridCard(
              product: _products[i],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(productId: _products[i].id),
                  ),
                );
              },
            ),
          ),
        ],
        if (_coupons.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Mã giảm giá'),
          const SizedBox(height: 8),
          ..._coupons.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CouponListItem(
                coupon: c,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VoucherDetailScreen(couponId: c.id),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
