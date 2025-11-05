import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../models/category.dart';
import '../../core/result.dart';

import '../../data/repo/product_repo.dart';
import '../../data/repo/category_repo.dart';
import '../../data/impl/product_repo_mock.dart';
import '../../data/impl/category_repo_mock.dart';

import '../../widgets/section_title.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/product_card.dart';
import '../detail/product_detail_screen.dart';
import 'hot_products_screen.dart';
import 'categories_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductRepo _productRepo = ProductRepoMock();
  final CategoryRepo _catRepo = CategoryRepoMock();

  final _scrollCtrl = ScrollController();

  // state
  List<Category> _cats = [];
  int? _selectedCat;

  final List<Product> _hot = [];
  final List<Product> _items = [];

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
    _cats = await _catRepo.list();
    _hot
      ..clear()
      ..addAll(await _productRepo.hot(limit: 20));
    await _loadFirst();
    if (mounted) setState(() {});
  }

  Future<void> _loadFirst() async {
    setState(() => _loading = true);
    final PageResult<Product> res = await _productRepo.list(
      page: 1,
      pageSize: 24,
      categoryId: _selectedCat,
    );
    setState(() {
      _items
        ..clear()
        ..addAll(res.data);
      _page = 1;
      _end = !res.hasMore;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loading || _end) return;
    setState(() => _loading = true);
    final PageResult<Product> res = await _productRepo.list(
      page: _page + 1,
      pageSize: 24,
      categoryId: _selectedCat,
    );
    setState(() {
      _items.addAll(res.data);
      _page += 1;
      _end = !res.hasMore;
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
          // ===== Sản phẩm hot =====
          SectionTitle(
            'Sản phẩm hot',
            trailing: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotProductsScreen()),
                );
              },
              child: const Text('View all'),
            ),
          ),
          if (_hot.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 300, // vertical card cao -> tránh overflow
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (_, i) => SizedBox(
                  width: 170,
                  child: ProductCard(
                    product: _hot[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(productId: _hot[i].id),
                      ),
                    ),
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: _hot.length,
              ),
            ),

          const SizedBox(height: 8),

          // ===== Danh mục =====
          SectionTitle(
            'Danh mục',
            trailing: TextButton(
              onPressed: () async {
                final selected = await Navigator.push<int?>(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
                if (selected != null) {
                  setState(() => _selectedCat = selected);
                  _loadFirst();
                }
              },
              child: const Text('View all'),
            ),
          ),
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
                ..._cats
                    .take(12)
                    .map(
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

          // ===== List sản phẩm theo danh mục (grid 2 cột) =====
          const SectionTitle('Sản phẩm theo danh mục'),
          if (_items.isEmpty && _loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.55, // vertical card: ảnh trên, text dưới
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _items.length,
                itemBuilder: (_, i) => ProductCard(
                  product: _items[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(productId: _items[i].id),
                    ),
                  ),
                ),
              ),
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
