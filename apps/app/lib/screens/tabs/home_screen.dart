import 'package:flutter/material.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/section_title.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/voucher_card.dart';
import '../../data/impl/coupon_repo_mock.dart';
import '../../data/impl/category_repo_mock.dart';
import '../../models/category.dart';
import '../detail/voucher_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bannerImages = const [
    'assets/images/OIP.webp',
    'assets/images/OIP.webp',
    'assets/images/OIP.webp',
  ];
  final repo = CouponRepoMock();
  final catRepo = CategoryRepoMock();

  final _scrollCtrl = ScrollController();
  final _items = <dynamic>[];
  List<Category> _cats = [];
  String? _selectedCat;
  String _sort = 'endAtAsc';
  int _page = 1;
  bool _loading = false;
  bool _end = false;

  @override
  void initState() {
    super.initState();
    _loadCats();
    _loadFirst();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCats() async {
    final cats = await catRepo.list();
    if (mounted) setState(() => _cats = cats);
  }

  Future<void> _loadFirst() async {
    setState(() => _loading = true);
    final data = await repo.list(
      page: 1,
      limit: 10,
      categoryId: _selectedCat,
      sort: _sort,
    );
    setState(() {
      _items
        ..clear()
        ..addAll(data);
      _page = 1;
      _end = data.length < 10;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loading || _end) return;
    setState(() => _loading = true);
    final data = await repo.list(
      page: _page + 1,
      limit: 10,
      categoryId: _selectedCat,
      sort: _sort,
    );
    setState(() {
      _items.addAll(data);
      _page += 1;
      if (data.length < 10) _end = true;
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
        children: [
          const SizedBox(height: 8),
          BannerSlider(images: bannerImages),
          const SizedBox(height: 16),

          SectionTitle(
            'Danh mục',
            trailing: DropdownButton<String>(
              value: _sort,
              items: const [
                DropdownMenuItem(value: 'endAtAsc', child: Text('Sắp hết hạn')),
                DropdownMenuItem(
                  value: 'priorityDesc',
                  child: Text('Ưu tiên cao'),
                ),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _sort = v);
                _loadFirst();
              },
            ),
          ),

          SizedBox(
            height: 44,
            child: ListView(
              primary: false,
              scrollDirection: Axis.horizontal,
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

          const SectionTitle('Sản phẩm hot'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 16 / 10,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 4,
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/OIP.webp', fit: BoxFit.cover),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'HOT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          const SectionTitle('Mã giảm giá'),
          if (_items.isEmpty && _loading)
            ...List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ..._items.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VoucherCard(
                title: c.title,
                code: c.code,
                shop: c.shopId,
                endAt: c.endAt,
                imageUrl: c.imageUrl?.startsWith('http') == true
                    ? c.imageUrl
                    : null,
                badge: (c.tags.contains('hot') || (c.priority ?? 0) >= 80)
                    ? 'HOT'
                    : null,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VoucherDetailScreen(couponId: c.id),
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
