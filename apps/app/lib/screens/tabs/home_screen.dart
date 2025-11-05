import 'package:flutter/material.dart';

import '../../widgets/banner_slider.dart';
import '../../widgets/section_title.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/product_card.dart';

import '../../models/product.dart';
import '../../models/category.dart';
import '../../core/result.dart';

import '../../data/repo/product_repo.dart';
import '../../data/repo/category_repo.dart';
import '../../data/impl/product_repo_mock.dart';
import '../../data/impl/category_repo_mock.dart';

import '../detail/product_detail_screen.dart';

import 'hot_products_screen.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Banner demo
  final _banners = const [
    'assets/images/slider1.png',
    'assets/images/slider2.png',
    'assets/images/slider3.png',
  ];

  // Repo (mock)
  final ProductRepo _productRepo = ProductRepoMock();
  final CategoryRepo _catRepo = CategoryRepoMock();

  // State chung
  final _scrollCtrl = ScrollController();
  List<Category> _cats = [];

  // Top trending (ngang)
  final List<Product> _hotProducts = [];
  // Gợi ý hôm nay (ngang)
  final List<Product> _suggestProducts = [];

  // Grid theo danh mục (2 cột + paging)
  final List<Product> _gridProducts = [];
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
    // danh mục
    _cats = await _catRepo.list();

    // top trending
    _hotProducts
      ..clear()
      ..addAll(await _productRepo.hot(limit: 10));

    // gợi ý hôm nay (lấy trang đầu)
    final PageResult<Product> first = await _productRepo.list(
      page: 1,
      pageSize: 12,
    );
    _suggestProducts
      ..clear()
      ..addAll(first.data);

    // grid theo danh mục (tất cả)
    await _loadFirstGrid();

    if (mounted) setState(() {});
  }

  Future<void> _loadFirstGrid() async {
    setState(() => _loading = true);
    final PageResult<Product> page = await _productRepo.list(
      page: 1,
      pageSize: 20,
      categoryId: _selectedCat,
    );
    setState(() {
      _gridProducts
        ..clear()
        ..addAll(page.data);
      _page = 1;
      _end = !page.hasMore;
      _loading = false;
    });
  }

  Future<void> _loadMoreGrid() async {
    if (_loading || _end) return;
    setState(() => _loading = true);
    final PageResult<Product> page = await _productRepo.list(
      page: _page + 1,
      pageSize: 20,
      categoryId: _selectedCat,
    );
    setState(() {
      _gridProducts.addAll(page.data);
      _page += 1;
      _end = !page.hasMore;
      _loading = false;
    });
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMoreGrid();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFirstGrid,
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          BannerSlider(images: _banners),

          // ===== Top trending (sản phẩm hot) =====
          SectionTitle(
            'Top trending',
            trailing: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotProductsScreen()),
                );
              },
              child: const Text('View All'),
            ),
          ),
          if (_hotProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 300, // tránh overflow
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (_, i) => SizedBox(
                  width: 170,
                  child: ProductCard(
                    product: _hotProducts[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(productId: _hotProducts[i].id),
                      ),
                    ),
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: _hotProducts.length,
              ),
            ),

          const SizedBox(height: 8),

          // ===== Gợi ý hôm nay (list ngang) =====
          const SectionTitle('Gợi ý hôm nay'),
          if (_suggestProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 300, // tránh overflow
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (_, i) => SizedBox(
                  width: 170,
                  child: ProductCard(
                    product: _suggestProducts[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          productId: _suggestProducts[i].id,
                        ),
                      ),
                    ),
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: _suggestProducts.length,
              ),
            ),

          const SizedBox(height: 12),

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
                      _loadFirstGrid();
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
                        _loadFirstGrid();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ===== Grid sản phẩm (2 cột) theo danh mục =====
          const SectionTitle('Sản phẩm theo danh mục'),
          if (_gridProducts.isEmpty && _loading)
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
                  childAspectRatio: 0.55, // bạn đã chỉnh để hết overflow
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _gridProducts.length,
                itemBuilder: (_, i) => ProductCard(
                  product: _gridProducts[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(productId: _gridProducts[i].id),
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
