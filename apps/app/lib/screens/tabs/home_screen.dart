import 'package:flutter/material.dart';

import '../../core/result.dart';
import '../../data/impl/category_repo_remote.dart';
import '../../data/impl/coupon_category_repo_remote.dart';
import '../../data/impl/coupon_repo_remote.dart';
import '../../data/impl/product_repo_remote.dart';
import '../../data/impl/shop_repo_remote.dart';
import '../../data/repo/category_repo.dart';
import '../../data/repo/coupon_category_repo.dart';
import '../../data/repo/coupon_repo.dart';
import '../../data/repo/product_repo.dart';
import '../../data/repo/shop_repo.dart';
import '../../models/category.dart';
import '../../models/coupon.dart';
import '../../models/coupon_category.dart';
import '../../models/product.dart';
import '../../models/shop.dart';
import '../../services/notification_scheduler.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/coupon_list_item.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/product_grid_card.dart';
import '../../widgets/section_title.dart';
import '../detail/product_detail_screen.dart';
import '../detail/source_detail_screen.dart';
import '../detail/voucher_detail_screen.dart';
import 'categories_screen.dart';
import 'coupon_categories_screen.dart';
import 'coupons_screen.dart';
import 'hot_coupons_screen.dart';
import 'hot_products_screen.dart';
import 'search_screen.dart';
import 'sources_screen.dart';

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
  final CouponCategoryRepo _couponCategoryRepo = CouponCategoryRepoRemote();

  bool _loading = true;
  String? _error;
  List<Coupon> _bannerCoupons = const [];
  List<Coupon> _hotCoupons = const [];
  List<Product> _hotProducts = const [];
  List<Category> _categoryHighlights = const [];
  List<CouponCategory> _couponHighlights = const [];
  List<Shop> _sources = const [];

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
        _couponRepo.hot(limit: 12),
        _productRepo.hot(limit: 10),
        _categoryRepo.highlights(limit: 6),
        _shopRepo.list(),
        _couponCategoryRepo.highlights(limit: 6),
      ]);

      final banners = (results[0] as PageResult<Coupon>).data;
      final hotCoupons = results[1] as List<Coupon>;
      final hotProducts = results[2] as List<Product>;
      final categories = results[3] as List<Category>;
      final shops = results[4] as List<Shop>;
      final couponCats = results[5] as List<CouponCategory>;

      if (!mounted) return;
      setState(() {
        _bannerCoupons = banners;
        _hotCoupons = hotCoupons;
        _hotProducts = hotProducts;
        _categoryHighlights = categories;
        _couponHighlights = couponCats;
        _sources = shops.take(8).toList();
        _loading = false;
      });
      await NotificationScheduler.instance.handleCoupons(hotCoupons);
      await NotificationScheduler.instance.handleProducts(hotProducts);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không thể tải dữ liệu';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        children: [
          _buildSearch(context),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_loading) _buildSkeleton() else ..._buildContent(context),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Icon(Icons.search),
              SizedBox(width: 8),
              Text('Tìm item, mã, nguồn...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: const [
        LoadingSkeleton(height: 160, width: double.infinity),
        SizedBox(height: 12),
        LoadingSkeleton(height: 220, width: double.infinity),
        SizedBox(height: 12),
        LoadingSkeleton(height: 220, width: double.infinity),
      ],
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    return [
      if (_bannerCoupons.isNotEmpty) _buildBannerSection(),
      SectionTitle(
        'Item hot',
        trailing: TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HotProductsScreen()),
          ),
          child: const Text('View all'),
        ),
      ),
      _buildHotProductsCarousel(),
      SectionTitle(
        'Mã hot',
        trailing: TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HotCouponsScreen()),
          ),
          child: const Text('View all'),
        ),
      ),
      _buildHotCouponsSection(),
      SectionTitle(
        'Danh mục item nổi bật',
        trailing: TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoriesScreen()),
          ),
          child: const Text('View all'),
        ),
      ),
      _buildCategoryHighlights(),
      SectionTitle(
        'Danh mục mã nổi bật',
        trailing: TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CouponCategoriesScreen()),
          ),
          child: const Text('View all'),
        ),
      ),
      _buildCouponCategoryHighlights(),
      SectionTitle(
        'Danh sách nguồn',
        trailing: TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SourcesScreen()),
          ),
          child: const Text('View deals'),
        ),
      ),
      _buildSourcesSection(),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildBannerSection() {
    final images = _bannerCoupons
        .map((coupon) => coupon.imageUrl ?? 'https://picsum.photos/seed/${coupon.id}/800/400')
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BannerSlider(images: images),
    );
  }

  Widget _buildHotProductsCarousel() {
    return SizedBox(
      height: 320,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _hotProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final slice = _hotProducts[index];
          return SizedBox(
            width: 220,
            child: ProductGridCard(
              product: slice,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: slice.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHotCouponsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _hotCoupons.map((coupon) {
          final isNew =
              coupon.startDate != null && DateTime.now().difference(coupon.startDate!).inDays <= 3;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CouponListItem(
              coupon: coupon,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoucherDetailScreen(couponId: coupon.id),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryHighlights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 16 / 10,
        ),
        itemCount: _categoryHighlights.length,
        itemBuilder: (_, index) {
          final cat = _categoryHighlights[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${cat.itemCount ?? 0} item đang giảm'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponCategoryHighlights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _couponHighlights
            .map(
              (cat) => Chip(
                label: Text('${cat.name} (${cat.couponCount ?? 0})'),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSourcesSection() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _sources.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final shop = _sources[index];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SourceDetailScreen(
                  sourceId: shop.id,
                  initial: shop,
                ),
              ),
            ),
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
                        backgroundImage:
                            shop.logoUrl != null ? NetworkImage(shop.logoUrl!) : null,
                        child: shop.logoUrl == null
                            ? const Icon(Icons.storefront, color: Colors.black54)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shop.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text('${shop.couponCount ?? 0} mã đang có'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
