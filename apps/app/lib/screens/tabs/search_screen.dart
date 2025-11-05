import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../models/coupon.dart';
import '../../core/result.dart';

import '../../data/repo/product_repo.dart';
import '../../data/repo/coupon_repo.dart';
import '../../data/impl/product_repo_mock.dart';
import '../../data/impl/coupon_repo_mock.dart';

import '../../widgets/product_card.dart';
import '../../widgets/coupon_list_item.dart';
import '../detail/product_detail_screen.dart';
import '../detail/voucher_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _productRepo = ProductRepoMock();
  final _couponRepo = CouponRepoMock();

  final _queryCtrl = TextEditingController();
  String _q = '';

  // state kết quả
  final List<Product> _products = [];
  final List<Coupon> _coupons = [];
  bool _loadingProducts = false;
  bool _loadingCoupons = false;

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _q.trim();
    setState(() {
      _loadingProducts = true;
      _loadingCoupons = true;
    });

    final PageResult<Product> p = await _productRepo.list(page: 1, pageSize: 40, q: q.isEmpty ? null : q);
    final PageResult<Coupon> c = await _couponRepo.list(page: 1, pageSize: 40, q: q.isEmpty ? null : q);

    if (!mounted) return;
    setState(() {
      _products
        ..clear()
        ..addAll(p.data);
      _coupons
        ..clear()
        ..addAll(c.data);
      _loadingProducts = false;
      _loadingCoupons = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          title: _SearchField(
            controller: _queryCtrl,
            onSubmitted: (v) {
              _q = v;
              _search();
            },
            onClear: () {
              _queryCtrl.clear();
              _q = '';
              _search();
            },
          ),
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(text: 'Sản phẩm'),
              Tab(text: 'Coupon'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ===== Tab Sản phẩm =====
            _loadingProducts
                ? const Center(child: CircularProgressIndicator())
                : (_products.isEmpty
                    ? const _EmptyState()
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.55,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (_, i) => ProductCard(
                            product: _products[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(productId: _products[i].id),
                              ),
                            ),
                          ),
                        ),
                      )),

            // ===== Tab Coupon =====
            _loadingCoupons
                ? const Center(child: CircularProgressIndicator())
                : (_coupons.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (_, i) => CouponListItem(
                          c: _coupons[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VoucherDetailScreen(couponId: _coupons[i].id),
                            ),
                          ),
                        ),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: _coupons.length,
                      )),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Tìm voucher, shop, sản phẩm…',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.4),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Không có kết quả'),
    );
  }
}
