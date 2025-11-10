import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../models/coupon.dart';
import '../../core/result.dart';

import '../../data/repo/coupon_repo.dart';
import '../../data/repo/category_repo.dart';
import '../../data/impl/coupon_repo_mock.dart';
import '../../data/impl/category_repo_mock.dart';

import '../../widgets/section_title.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/coupon_list_item.dart';
import '../detail/voucher_detail_screen.dart';
import 'hot_coupons_screen.dart';
import 'coupon_categories_screen.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});
  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final CouponRepo _couponRepo = CouponRepoMock();
  final CategoryRepo _catRepo = CategoryRepoMock();

  final _scrollCtrl = ScrollController();

  // state
  List<Category> _cats = [];
  int? _selectedCat;

  final List<Coupon> _hot = [];
  final List<Coupon> _items = [];

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
      ..addAll(await _couponRepo.hot(limit: 20));
    await _loadFirst();
    if (mounted) setState(() {});
  }

  Future<void> _loadFirst() async {
    setState(() => _loading = true);
    final PageResult<Coupon> res = await _couponRepo.list(
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
    final PageResult<Coupon> res = await _couponRepo.list(
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
          // ===== Mã hot =====
          SectionTitle(
            'Mã hot',
            trailing: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotCouponsScreen()),
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
              height: 200, // đủ cho coupon item ngang
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (_, i) => SizedBox(
                  width: 320, // item ngang cố định
                  child: CouponListItem(
                    coupon: _hot[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VoucherDetailScreen(couponId: _hot[i].id),
                      ),
                    ),
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: _hot.length,
              ),
            ),

          const SizedBox(height: 8),

          // ===== Danh mục mã =====
          SectionTitle(
            'Danh mục mã',
            trailing: TextButton(
              onPressed: () async {
                final selected = await Navigator.push<int?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CouponCategoriesScreen(),
                  ),
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

          // ===== List mã theo danh mục =====
          const SectionTitle('Mã theo danh mục'),
          if (_items.isEmpty && _loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
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
