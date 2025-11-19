import 'package:flutter/material.dart';

import '../../core/result.dart';
import '../../data/impl/category_repo_remote.dart';
import '../../data/impl/coupon_repo_remote.dart';
import '../../data/impl/product_repo_remote.dart';
import '../../data/impl/shop_repo_remote.dart';
import '../../data/repo/category_repo.dart';
import '../../data/repo/coupon_repo.dart';
import '../../data/repo/product_repo.dart';
import '../../data/repo/shop_repo.dart';
import '../../models/category.dart';
import '../../models/coupon.dart';
import '../../models/product.dart';
import '../../models/shop.dart';
import '../../widgets/coupon_list_item.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/product_grid_card.dart';
import '../../widgets/section_title.dart';
import '../detail/product_detail_screen.dart';
import '../detail/source_detail_screen.dart';
import '../detail/voucher_detail_screen.dart';
import 'coupons_screen.dart';
import 'hot_coupons_screen.dart';
import 'hot_products_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<int>? reloadTrigger;
  const HomeScreen({super.key, this.reloadTrigger});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepo _productRepo = ProductRepoRemote();
  final CouponRepo _couponRepo = CouponRepoRemote();
  final CategoryRepo _categoryRepo = CategoryRepoRemote();
  final ShopRepo _shopRepo = ShopRepoRemote();

  bool _loading = true;
  String? _error;
  List<Coupon> _bannerCoupons = const [];
  List<Coupon> _hotCoupons = const [];
  List<Product> _hotProducts = const [];
  List<Category> _categories = const [];
  List<_SourceHighlight> _sources = const [];

  @override
  void initState() {
    super.initState();
    widget.reloadTrigger?.addListener(_handleReload);
    _load();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadTrigger != widget.reloadTrigger) {
      oldWidget.reloadTrigger?.removeListener(_handleReload);
      widget.reloadTrigger?.addListener(_handleReload);
    }
  }

  void _handleReload() {
    _load();
  }

  @override
  void dispose() {
    widget.reloadTrigger?.removeListener(_handleReload);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _couponRepo.list(page: 1, pageSize: 5, badgeKey: 'hot'),
        _couponRepo.hot(limit: 10),
        _productRepo.hot(limit: 8),
        _categoryRepo.list(),
        _shopRepo.list(),
      ]);

      final banners = (results[0] as PageResult<Coupon>).data;
      final hotCoupons = results[1] as List<Coupon>;
      final hotProducts = results[2] as List<Product>;
      final categories = results[3] as List<Category>;
      final shops = results[4] as List<Shop>;
      final highlights = await _buildSourceHighlights(shops.take(5).toList());

      if (!mounted) return;
      setState(() {
        _bannerCoupons = banners;
        _hotCoupons = hotCoupons;
        _hotProducts = hotProducts;
        _categories = categories;
        _sources = highlights;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không thể tải dữ liệu';
      });
    }
  }

  Future<List<_SourceHighlight>> _buildSourceHighlights(List<Shop> shops) async {
    final futures = shops.map((shop) async {
      try {
        final page = await _couponRepo.list(page: 1, pageSize: 1, shopId: shop.id);
        final total = page.meta?['total'] as int? ?? page.data.length;
        return _SourceHighlight(shop: shop, couponCount: total);
      } catch (_) {
        return _SourceHighlight(shop: shop, couponCount: 0);
      }
    });
    return Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: TextButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: Text(_error!),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          _buildSearchCard(context),
          const SizedBox(height: 12),
          if (_bannerCoupons.isNotEmpty) _buildBanner(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionTitle(
              'Mã hot',
              trailing: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotCouponsScreen()),
                ),
                child: const Text('Xem tất cả'),
              ),
            ),
          ),
          _buildHotCouponsSection(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const SectionTitle('Danh mục nổi bật'),
          ),
          _buildCategories(),
          const SizedBox(height: 24),
          if (_sources.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const SectionTitle('Deal theo nguồn'),
            ),
            _buildSources(),
            const SizedBox(height: 24),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionTitle(
              'Sản phẩm nổi bật',
              trailing: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotProductsScreen()),
                ),
                child: const Text('Xem tất cả'),
              ),
            ),
          ),
          _buildHotProductsSection(),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: const [
              Icon(Icons.search),
              SizedBox(width: 12),
              Expanded(child: Text('Tìm mã giảm giá, sản phẩm, cửa hàng...')),
              Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: _bannerCoupons.length,
        controller: PageController(viewportFraction: .92),
        itemBuilder: (_, index) {
          final coupon = _bannerCoupons[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoucherDetailScreen(couponId: coupon.id),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: coupon.imageUrl != null
                          ? Image.network(
                              coupon.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.blueGrey.shade100),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(.65),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coupon.isPercent
                              ? 'Giảm ${coupon.discountValue}%'
                              : 'Giảm ${coupon.discountValue}đ',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHotCouponsSection() {
    if (_hotCoupons.isEmpty) {
      return SizedBox(
        height: 140,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, __) => const LoadingSkeleton(width: 260, height: 120),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemCount: 4,
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) => SizedBox(
          width: 300,
          child: CouponListItem(
            coupon: _hotCoupons[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VoucherDetailScreen(couponId: _hotCoupons[index].id),
              ),
            ),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _hotCoupons.length,
      ),
    );
  }

  Widget _buildCategories() {
    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }
    final list = _categories.take(8).toList();
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final cat = list[index];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CouponsScreen(initialCategoryId: cat.id),
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.label_outline),
                  const Spacer(),
                  Text(
                    cat.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: list.length,
      ),
    );
  }

  Widget _buildSources() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final highlight = _sources[index];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SourceDetailScreen(
                  sourceId: highlight.shop.id,
                  initial: highlight.shop,
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: highlight.shop.logoUrl != null
                            ? NetworkImage(highlight.shop.logoUrl!)
                            : null,
                        child: highlight.shop.logoUrl == null
                            ? const Icon(Icons.storefront, color: Colors.black54)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          highlight.shop.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${highlight.couponCount} mã đang có',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _sources.length,
      ),
    );
  }

  Widget _buildHotProductsSection() {
    if (_hotProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
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
        itemCount: _hotProducts.length,
        itemBuilder: (_, i) => ProductGridCard(
          product: _hotProducts[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: _hotProducts[i].id),
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceHighlight {
  final Shop shop;
  final int couponCount;
  _SourceHighlight({required this.shop, required this.couponCount});
}
