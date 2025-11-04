import 'package:flutter/material.dart';

import '../../widgets/section_title.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/voucher_card.dart';

import '../../models/category.dart';
import '../../models/coupon.dart';
import '../../core/result.dart';

import '../../data/repo/category_repo.dart';
import '../../data/repo/coupon_repo.dart';

import '../../data/impl/category_repo_mock.dart';
import '../../data/impl/coupon_repo_mock.dart';

import '../detail/voucher_detail_screen.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});
  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  // Repo (mock)
  final CategoryRepo _catRepo = CategoryRepoMock();
  final CouponRepo _couponRepo = CouponRepoMock();

  // State
  final _scrollCtrl = ScrollController();

  List<Category> _cats = [];
  final _hotCoupons = <Coupon>[];
  final _coupons = <Coupon>[];

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
    // Danh mục
    _cats = await _catRepo.list();

    // Mã hot
    _hotCoupons
      ..clear()
      ..addAll(await _couponRepo.hot(limit: 8));

    // Trang đầu
    await _loadFirst();

    if (mounted) setState(() {});
  }

  Future<void> _loadFirst() async {
    setState(() => _loading = true);
    final PageResult<Coupon> page = await _couponRepo.list(
      page: 1,
      pageSize: 20,
      categoryId: _selectedCat,
    );
    setState(() {
      _coupons
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
    final PageResult<Coupon> page = await _couponRepo.list(
      page: _page + 1,
      pageSize: 20,
      categoryId: _selectedCat,
    );
    setState(() {
      _coupons.addAll(page.data);
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
          // Danh mục mã áp dụng
          const SectionTitle('Danh mục mã áp dụng'),
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
                ..._cats.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: _selectedCat == c.id,
                        onSelected: (_) {
                          setState(() => _selectedCat = c.id);
                          _loadFirst();
                        },
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Mã giảm giá hot (tuỳ chọn: hiển thị đầu trang)
          if (_hotCoupons.isNotEmpty) const SectionTitle('Mã hot'),
          if (_hotCoupons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _hotCoupons
                    .map(
                      (c) => SizedBox(
                        width: 170,
                        child: VoucherCard(
                          c: c,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VoucherDetailScreen(couponId: c.id),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          if (_hotCoupons.isNotEmpty) const SizedBox(height: 12),

          // Danh sách mã
          const SectionTitle('Danh sách mã'),
          if (_coupons.isEmpty && _loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _coupons
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: VoucherCard(
                          c: c,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VoucherDetailScreen(couponId: c.id),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
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
