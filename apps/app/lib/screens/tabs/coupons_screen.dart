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
  final int? initialCategoryId;
  final String? initialSourceId;
  final String? initialBadgeKey;
  final String? initialDiscountType;
  const CouponsScreen({
    super.key,
    this.initialCategoryId,
    this.initialSourceId,
    this.initialBadgeKey,
    this.initialDiscountType,
  });

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
  String? _selectedDiscountType;
  String _sort = 'newest';
  String? _expiryFilter;

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
    _selectedCategory = widget.initialCategoryId;
    _selectedSource = widget.initialSourceId;
    _selectedBadge = widget.initialBadgeKey;
    _selectedDiscountType = widget.initialDiscountType;
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
        sort: _apiSort(),
        discountType: _selectedDiscountType,
        expiresTo: _expiryDate(),
      );
      if (!mounted) return;
      final data = _filterAndSort(res.data);
      setState(() {
        _items
          ..clear()
          ..addAll(data);
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
        sort: _apiSort(),
        discountType: _selectedDiscountType,
        expiresTo: _expiryDate(),
      );
      if (!mounted) return;
      final data = _filterAndSort(res.data);
      setState(() {
        _items.addAll(data);
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
            'Mã nổi bật',
            trailing: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HotCouponsScreen(),
                ),
              ),
              child: const Text('Xem tất cả'),
            ),
          ),
          _buildHotCouponsSection(),

          const SizedBox(height: 12),
          SectionTitle(
            'Danh mục',
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
              child: const Text('Xem tất cả'),
            ),
          ),
          _buildCategoryChips(),

          const SizedBox(height: 12),
          if (_sources.isNotEmpty) ...[
            const SectionTitle('Nguồn'),
            _buildSourceChips(),
            const SizedBox(height: 12),
          ],
          if (_badges.isNotEmpty) ...[
            const SectionTitle('Huy hiệu'),
            _buildBadgeChips(),
            const SizedBox(height: 12),
          ],

          _buildFilterBar(),
          const SectionTitle('Tất cả mã'),
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

  List<Coupon> _filterAndSort(List<Coupon> source) {
    var filtered = List<Coupon>.from(source);
    if (_selectedDiscountType != null && _selectedDiscountType!.isNotEmpty) {
      final target = _selectedDiscountType!.toUpperCase();
      filtered = filtered
          .where((c) => c.discountType.toUpperCase() == target)
          .toList();
    }
    switch (_sort) {
      case 'ending':
        filtered.sort(
          (a, b) => (a.endAt ?? DateTime(2100)).compareTo(b.endAt ?? DateTime(2100)),
        );
        break;
      case 'value':
        filtered.sort((a, b) => b.discountValue.compareTo(a.discountValue));
        break;
      case 'hot':
        filtered.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
        break;
      default:
        filtered.sort((a, b) => b.id.compareTo(a.id));
    }
    return filtered;
  }

  String? _apiSort() {
    switch (_sort) {
      case 'hot':
        return 'hot';
      default:
        return null;
    }
  }

  DateTime? _expiryDate() {
    final now = DateTime.now();
    switch (_expiryFilter) {
      case 'soon':
        return now.add(const Duration(days: 7));
      case 'month':
        return now.add(const Duration(days: 30));
      default:
        return null;
    }
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(width: 200, child: _categoryDropdown()),
          SizedBox(width: 200, child: _sourceDropdown()),
          SizedBox(width: 200, child: _discountDropdown()),
           SizedBox(width: 200, child: _expiryDropdown()),
          SizedBox(width: 200, child: _sortDropdown()),
        ],
      ),
    );
  }

  Widget _categoryDropdown() {
    return DropdownButtonFormField<int?>(
      decoration: const InputDecoration(labelText: 'Danh mục mã'),
      value: _selectedCategory,
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Tất cả')),
        ..._categories.map(
          (cat) => DropdownMenuItem<int?>(
            value: cat.id,
            child: Text(cat.name),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedCategory = value);
        _loadFirst();
      },
    );
  }

  Widget _sourceDropdown() {
    return DropdownButtonFormField<String?>(
      decoration: const InputDecoration(labelText: 'Nguồn'),
      value: _selectedSource,
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Tất cả')),
        ..._sources.map(
          (shop) => DropdownMenuItem<String?>(
            value: shop.id,
            child: Text(shop.name),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedSource = value);
        _loadFirst();
      },
    );
  }

  Widget _discountDropdown() {
    const options = [
      DropdownMenuItem<String?>(value: null, child: Text('Tất cả loại giảm')),
      DropdownMenuItem<String?>(value: 'PERCENT', child: Text('Giảm %')),
      DropdownMenuItem<String?>(value: 'FIXED_AMOUNT', child: Text('Giảm tiền')),
      DropdownMenuItem<String?>(value: 'FREESHIP', child: Text('Freeship')),
      DropdownMenuItem<String?>(value: 'GIFT', child: Text('Quà tặng')),
    ];
    return DropdownButtonFormField<String?>(
      decoration: const InputDecoration(labelText: 'Loại giảm'),
      value: _selectedDiscountType,
      items: options,
      onChanged: (value) {
        setState(() => _selectedDiscountType = value);
        _loadFirst();
      },
    );
  }

  Widget _expiryDropdown() {
    return DropdownButtonFormField<String?>(
      decoration: const InputDecoration(labelText: 'Hạn sử dụng'),
      value: _expiryFilter,
      items: const [
        DropdownMenuItem<String?>(value: null, child: Text('Tất cả')),
        DropdownMenuItem<String?>(value: 'soon', child: Text('Sắp hết hạn (<7 ngày)')),
        DropdownMenuItem<String?>(value: 'month', child: Text('Trong 30 ngày')),
      ],
      onChanged: (value) {
        setState(() => _expiryFilter = value);
        _loadFirst();
      },
    );
  }

  Widget _sortDropdown() {
    const labels = {
      'newest': 'Mới nhất',
      'ending': 'Sắp hết hạn',
      'value': 'Giảm mạnh nhất',
      'hot': 'Phổ biến',
    };
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Sắp xếp'),
      value: _sort,
      items: labels.entries
          .map(
            (e) => DropdownMenuItem<String>(
              value: e.key,
              child: Text(e.value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _sort = value);
        _loadFirst();
      },
    );
  }
}
