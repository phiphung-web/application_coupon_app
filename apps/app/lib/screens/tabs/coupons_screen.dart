import 'package:flutter/material.dart' hide Badge;

import '../../models/category.dart';
import '../../models/coupon.dart';
import '../../models/shop.dart';
import '../../models/badge.dart';
import '../../core/result.dart';

import '../../data/repo/coupon_repo.dart';
import '../../data/repo/category_repo.dart';
import '../../data/repo/shop_repo.dart';
import '../../data/repo/badge_repo.dart';
import '../../data/impl/coupon_repo_remote.dart';
import '../../data/impl/category_repo_remote.dart';
import '../../data/impl/shop_repo_remote.dart';
import '../../data/impl/badge_repo_remote.dart';

import '../../widgets/section_title.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/coupon_list_item.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/retry_view.dart';
import '../detail/voucher_detail_screen.dart';
import 'hot_coupons_screen.dart';
import 'coupon_categories_screen.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final CouponRepo _couponRepo = CouponRepoRemote();
  final CategoryRepo _categoryRepo = CategoryRepoRemote();
  final ShopRepo _shopRepo = ShopRepoRemote();
  final BadgeRepo _badgeRepo = BadgeRepoRemote();

  final _scrollCtrl = ScrollController();

  List<Category> _categories = [];
  int? _selectedCategory;
  List<Shop> _sources = [];
  String? _selectedSource;
  List<Badge> _badges = [];
  String? _selectedBadge;

  final List<Coupon> _hot = [];
  final List<Coupon> _items = [];

  int _page = 1;
  bool _loading = false;
  bool _end = false;
  bool _fallbackNotified = false;
  String? _error;

  bool _loadingHotCoupons = true;
  String? _hotCouponsError;

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
    await _loadFilters();
    await _loadHotCoupons();
    await _loadFirst();
  }

  Future<void> _loadFilters() async {
    try {
      final cats = await _categoryRepo.list();
      final sources = await _shopRepo.list();
      final badges = await _badgeRepo.list();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _sources = sources;
        _badges = badges;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _loadHotCoupons() async {
    setState(() {
      _loadingHotCoupons = true;
      _hotCouponsError = null;
    });
    try {
      final data = await _couponRepo.hot(limit: 20);
      if (!mounted) return;
      setState(() {
        _hot
          ..clear()
          ..addAll(data);
        _loadingHotCoupons = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingHotCoupons = false;
        _hotCouponsError = 'Failed to load hot coupons.';
      });
    }
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final PageResult<Coupon> res = await _couponRepo.list(
        page: 1,
        pageSize: 24,
        categoryId: _selectedCategory,
        shopId: _selectedSource,
        badgeKey: _selectedBadge,
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(res.data);
        _page = res.nextPage;
        _end = !res.hasMore;
        _loading = false;
      });
      _maybeNotifyFallback(res.fromFallback);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load coupons.';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _end) return;
    setState(() => _loading = true);
    try {
      final PageResult<Coupon> res = await _couponRepo.list(
        page: _page,
        pageSize: 24,
        categoryId: _selectedCategory,
        shopId: _selectedSource,
        badgeKey: _selectedBadge,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(res.data);
        _page = res.nextPage;
        _end = !res.hasMore;
        _loading = false;
      });
      _maybeNotifyFallback(res.fromFallback);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load coupons.';
      });
    }
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _maybeNotifyFallback(bool fromFallback) {
    if (!fromFallback || _fallbackNotified) return;
    _fallbackNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot reach server, showing cached/demo data for now.',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFirst,
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SectionTitle(
            'Hot coupons',
            trailing: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HotCouponsScreen(),
                ),
              ),
              child: const Text('View all'),
            ),
          ),
          _buildHotCouponsSection(),

          const SizedBox(height: 12),
          SectionTitle(
            'Categories',
            trailing: TextButton(
              onPressed: () async {
                final selected = await Navigator.push<int?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CouponCategoriesScreen(),
                  ),
                );
                if (selected != null) {
                  setState(() => _selectedCategory = selected);
                  _loadFirst();
                }
              },
              child: const Text('View all'),
            ),
          ),
          _buildCategoryChips(),

          const SizedBox(height: 12),
          if (_sources.isNotEmpty) ...[
            const SectionTitle('Sources'),
            _buildSourceChips(),
            const SizedBox(height: 12),
          ],
          if (_badges.isNotEmpty) ...[
            const SectionTitle('Badges'),
            _buildBadgeChips(),
            const SizedBox(height: 12),
          ],

          const SectionTitle('All coupons'),
          if (_items.isEmpty && _loading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: buildGridSkeleton(count: 3, height: 140),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: RetryView(
                message: _error!,
                onRetry: _loadFirst,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) => CouponListItem(
                coupon: _items[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VoucherDetailScreen(couponId: _items[i].id),
                  ),
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: _items.length,
            ),

          if (_loading && _items.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_end)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No more coupons')),
            ),
        ],
      ),
    );
  }

  Widget _buildHotCouponsSection() {
    if (_loadingHotCoupons) {
      return SizedBox(
        height: 132,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, __) =>
              const LoadingSkeleton(width: 320, height: 120),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemCount: 3,
        ),
      );
    }
    if (_hotCouponsError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: RetryView(
          message: _hotCouponsError!,
          onRetry: _loadHotCoupons,
        ),
      );
    }
    if (_hot.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No hot coupons available right now.'),
      );
    }
    return SizedBox(
      height: 132,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => SizedBox(
          width: 320,
          child: CouponListItem(
            coupon: _hot[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VoucherDetailScreen(couponId: _hot[i].id),
              ),
            ),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _hot.length,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        primary: false,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryPill(
              'All',
              onTap: () {
                setState(() => _selectedCategory = null);
                _loadFirst();
              },
            ),
          ),
          ..._categories.take(12).map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c.name),
                    selected: _selectedCategory == c.id,
                    onSelected: (_) {
                      setState(() => _selectedCategory = c.id);
                      _loadFirst();
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSourceChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        primary: false,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: _selectedSource == null,
              onSelected: (_) {
                setState(() => _selectedSource = null);
                _loadFirst();
              },
            ),
          ),
          ..._sources.map(
            (s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(s.name),
                selected: _selectedSource == s.id,
                onSelected: (_) {
                  setState(() => _selectedSource = s.id);
                  _loadFirst();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedBadge == null,
            onSelected: (_) {
              setState(() => _selectedBadge = null);
              _loadFirst();
            },
          ),
          ..._badges.map(
            (b) => FilterChip(
              label: Text(b.label),
              selected: _selectedBadge == b.key,
              onSelected: (_) {
                setState(() => _selectedBadge = b.key);
                _loadFirst();
              },
            ),
          ),
        ],
      ),
    );
  }
}
