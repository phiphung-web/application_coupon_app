import 'package:flutter/material.dart';

import '../../core/result.dart';
import '../../data/impl/category_repo_remote.dart';
import '../../data/impl/product_repo_remote.dart';
import '../../data/impl/shop_repo_remote.dart';
import '../../data/repo/category_repo.dart';
import '../../data/repo/product_repo.dart';
import '../../data/repo/shop_repo.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/shop.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/product_grid_card.dart';
import '../../widgets/retry_view.dart';
import '../detail/product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductRepo _repo = ProductRepoRemote();
  final CategoryRepo _categoryRepo = CategoryRepoRemote();
  final ShopRepo _shopRepo = ShopRepoRemote();

  final _scroll = ScrollController();
  final _items = <Product>[];

  List<Category> _categories = [];
  List<Shop> _shops = [];
  int _page = 1;
  bool _loading = false;
  bool _end = false;
  bool _fallbackNotified = false;
  bool _loadingFilters = true;
  String? _error;
  int? _selectedCategory;
  String? _selectedShop;
  String? _sort;
  String? _itemType;
  int? _priceMin;
  int? _priceMax;
  bool _hasCouponOnly = false;
  final TextEditingController _minCtrl = TextEditingController();
  final TextEditingController _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _loadFilters();
    if (!mounted) return;
    await _loadFirst();
  }

  Future<void> _loadFilters() async {
    try {
      final cats = await _categoryRepo.list();
      final shops = await _shopRepo.list();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _shops = shops;
        _loadingFilters = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingFilters = false;
      });
    }
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final PageResult<Product> data = await _repo.list(
        page: 1,
        pageSize: 20,
        categoryId: _selectedCategory,
        shopId: _selectedShop,
        sort: _sort,
        itemType: _itemType,
        minPrice: _priceMin,
        maxPrice: _priceMax,
        hasCoupon: _hasCouponOnly ? true : null,
      );
      setState(() {
        _items
          ..clear()
          ..addAll(data.data);
        _page = data.nextPage;
        _end = !data.hasMore;
        _loading = false;
      });
      _maybeNotifyFallback(data.fromFallback);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Khong the tai danh sach san pham.';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _end) return;
    setState(() => _loading = true);
    final PageResult<Product> data = await _repo.list(
      page: _page,
      pageSize: 20,
      categoryId: _selectedCategory,
      shopId: _selectedShop,
      sort: _sort,
      itemType: _itemType,
      minPrice: _priceMin,
      maxPrice: _priceMax,
      hasCoupon: _hasCouponOnly ? true : null,
    );
    setState(() {
      _items.addAll(data.data);
      _page = data.nextPage;
      _end = !data.hasMore;
      _loading = false;
    });
    _maybeNotifyFallback(data.fromFallback);
  }

  void _maybeNotifyFallback(bool fromFallback) {
    if (!fromFallback || _fallbackNotified) return;
    _fallbackNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Khong ket noi duoc server, dang tam hien thi du lieu demo.',
          ),
        ),
      );
    });
  }

  void _selectCategory(int? id) {
    if (_selectedCategory == id) return;
    setState(() => _selectedCategory = id);
    _loadFirst();
  }

  void _selectShop(String? id) {
    if (_selectedShop == id) return;
    setState(() => _selectedShop = id);
    _loadFirst();
  }

  void _selectSort(String? value) {
    if (_sort == value) return;
    setState(() => _sort = value);
    _loadFirst();
  }

  _SortOption get _currentSort =>
      _sortOptions.firstWhere((opt) => opt.value == _sort, orElse: () => _sortOptions.first);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFirst,
      child: ListView(
        controller: _scroll,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tat ca san pham',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                PopupMenuButton<_SortOption>(
                  tooltip: 'Sap xep',
                  onSelected: (value) => _selectSort(value.value),
                  itemBuilder: (_) => _sortOptions
                      .map(
                        (opt) => PopupMenuItem<_SortOption>(
                          value: opt,
                          child: Row(
                            children: [
                              Icon(opt.icon, size: 16),
                              const SizedBox(width: 8),
                              Text(opt.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  child: Chip(
                    avatar: Icon(_currentSort.icon, size: 16),
                    label: Text(_currentSort.label),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (!_loadingFilters && _categories.isNotEmpty) _buildCategoryChips(),
          if (!_loadingFilters && _shops.isNotEmpty) _buildShopChips(),
          const SizedBox(height: 8),
          _buildItemTypeChips(),
          const SizedBox(height: 8),
          _buildPriceInputs(),
          const SizedBox(height: 8),
          _buildCouponToggle(),
          if (_items.isEmpty && _loading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: buildGridSkeleton(
                  count: 4,
                  height: 200,
                ),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: RetryView(
                message: _error!,
                onRetry: _loadFirst,
              ),
            ),
          Padding(
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
              itemCount: _items.length,
              itemBuilder: (_, i) => ProductGridCard(
                product: _items[i],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(productId: _items[i].id),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_end)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('Da het du lieu')),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Tat ca'),
              selected: _selectedCategory == null,
              onSelected: (_) => _selectCategory(null),
            ),
          ),
          ..._categories.take(12).map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c.name),
                    selected: _selectedCategory == c.id,
                    onSelected: (_) => _selectCategory(c.id),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildShopChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Nguon'),
              selected: _selectedShop == null,
              onSelected: (_) => _selectShop(null),
            ),
          ),
          ..._shops.take(12).map(
                (s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s.name),
                    selected: _selectedShop == s.id,
                    onSelected: (_) => _selectShop(s.id),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildItemTypeChips() {
    const types = [
      ('PRODUCT', 'Product'),
      ('APP', 'App'),
      ('GAME', 'Game'),
      ('SERVICE', 'Service'),
    ];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Tất cả loại'),
              selected: _itemType == null,
              onSelected: (_) {
                setState(() => _itemType = null);
                _loadFirst();
              },
            ),
          ),
          ...types.map(
            (type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(type.$2),
                selected: _itemType == type.$1,
                onSelected: (_) {
                  setState(() => _itemType = type.$1);
                  _loadFirst();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInputs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _minCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giá min',
                prefixIcon: Icon(Icons.price_check),
              ),
              onSubmitted: (_) => _applyPriceFilter(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _maxCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giá max',
                prefixIcon: Icon(Icons.price_change),
              ),
              onSubmitted: (_) => _applyPriceFilter(),
            ),
          ),
          IconButton(
            onPressed: _applyPriceFilter,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponToggle() {
    return SwitchListTile(
      value: _hasCouponOnly,
      onChanged: (value) {
        setState(() => _hasCouponOnly = value);
        _loadFirst();
      },
      title: const Text('Chỉ hiển thị item có mã giảm giá'),
    );
  }

  void _applyPriceFilter() {
    setState(() {
      _priceMin = int.tryParse(_minCtrl.text);
      _priceMax = int.tryParse(_maxCtrl.text);
    });
    _loadFirst();
  }
}

class _SortOption {
  final String? value;
  final String label;
  final IconData icon;

  const _SortOption(this.value, this.label, this.icon);
}

const List<_SortOption> _sortOptions = [
  _SortOption(null, 'Mặc định', Icons.sort),
  _SortOption('newest', 'Mới nhất', Icons.fiber_new),
  _SortOption('popular', 'Được xem nhiều', Icons.visibility),
  _SortOption('price_asc', 'Giá tăng dần', Icons.arrow_upward),
  _SortOption('price_desc', 'Giá giảm dần', Icons.arrow_downward),
];
