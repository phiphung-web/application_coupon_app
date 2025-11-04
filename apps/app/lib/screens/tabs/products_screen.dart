import 'package:flutter/material.dart';

import '../../widgets/section_title.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/product_tile.dart';

import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/coupon.dart';
import '../../core/result.dart';

import '../../data/repo/category_repo.dart';
import '../../data/repo/product_repo.dart';
import '../../data/repo/coupon_repo.dart';

import '../../data/impl/category_repo_mock.dart';
import '../../data/impl/product_repo_mock.dart';
import '../../data/impl/coupon_repo_mock.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Repo (mock cho demo)
  final CategoryRepo _catRepo = CategoryRepoMock();
  final ProductRepo _productRepo = ProductRepoMock();
  final CouponRepo _couponRepo = CouponRepoMock();

  // State
  final _scrollCtrl = ScrollController();

  List<Category> _cats = [];
  final _hotProducts = <Product>[];
  final _products = <Product>[];
  List<Coupon> _allCoupons = [];

  int? _selectedCat;
  int _page = 1;
  bool _loading = false;
  bool _end = false;

  @override
  void initState() {
    super.initState();
    _init();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // tải danh mục
    _cats = await _catRepo.list();

    // lấy tất cả coupon (mock) để tính giá giảm cho item
    final cp = await _couponRepo.list(pageSize: 999);
    _allCoupons = cp.data;

    // sản phẩm hot
    _hotProducts
      ..clear()
      ..addAll(await _productRepo.hot(limit: 8));

    await _loadFirst();

    if (mounted) setState(() {});
  }

  Future<void> _loadFirst() async {
    setState(() => _loading = true);
    final PageResult<Product> page = await _productRepo.list(
      page: 1,
      pageSize: 20,
      categoryId: _selectedCat,
    );
    setState(() {
      _products
        ..clear()
        ..addAll(page.data);
      _page = 1;
      _end = !page.hasMore;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loading || _end) return;
    setState(() => _loading = true);
    final PageResult<Product> page = await _productRepo.list(
      page: _page + 1,
      pageSize: 20,
      categoryId: _selectedCat,
    );
    setState(() {
      _products.addAll(page.data);
      _page += 1;
      _end = !page.hasMore;
      _loading = false;
    });
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFirst,
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Danh mục
          const SectionTitle('Danh mục'),
          SizedBox(
            height: 44,
            child: ListView(
              primary: false,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryPill(
                    'Tất cả',
                    onTap: () {
                      setState(() => _selectedCat = null);
                      _loadFirst();
                    },
                  ),
                ),
                ..._cats.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.name),
                      selected: _selectedCat == c.id,
                      onSelected: (_) {
                        setState(() => _selectedCat = c.id);
                        _loadFirst();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Sản phẩm hot (horizontal)
          const SectionTitle('Sản phẩm hot'),
          if (_hotProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (_, i) => SizedBox(
                  width: 300,
                  child: ProductTile(
                    product: _hotProducts[i],
                    coupons: _allCoupons,
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: _hotProducts.length,
              ),
            ),

          const SizedBox(height: 12),

          // Tất cả sản phẩm (infinite scroll)
          const SectionTitle('Tất cả sản phẩm'),
          if (_products.isEmpty && _loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Column(
              children: _products
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ProductTile(product: p, coupons: _allCoupons),
                    ),
                  )
                  .toList(),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_end)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('Hết dữ liệu')),
            ),
        ],
      ),
    );
  }
}
