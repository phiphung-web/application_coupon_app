import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/result.dart';
import '../../data/impl/coupon_repo_remote.dart';
import '../../data/impl/product_repo_remote.dart';
import '../../data/impl/shop_repo_remote.dart';
import '../../data/repo/coupon_repo.dart';
import '../../data/repo/product_repo.dart';
import '../../data/repo/shop_repo.dart';
import '../../models/coupon.dart';
import '../../models/product.dart';
import '../../models/shop.dart';
import '../../services/favorites_service.dart';
import '../../widgets/coupon_list_item.dart';
import '../../widgets/product_grid_card.dart';

class SourceDetailScreen extends StatefulWidget {
  final String sourceId;
  final Shop? initial;
  const SourceDetailScreen({
    super.key,
    required this.sourceId,
    this.initial,
  });

  @override
  State<SourceDetailScreen> createState() => _SourceDetailScreenState();
}

class _SourceDetailScreenState extends State<SourceDetailScreen> {
  final ShopRepo _shopRepo = ShopRepoRemote();
  final CouponRepo _couponRepo = CouponRepoRemote();
  final ProductRepo _productRepo = ProductRepoRemote();
  final FavoritesService _favorites = FavoritesService.instance;

  Shop? _source;
  bool _loading = true;
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    Shop? shop = widget.initial;
    if (shop == null) {
      shop = await _shopRepo.get(widget.sourceId);
      shop ??= (await _shopRepo.list()).firstWhere(
        (s) => s.id == widget.sourceId,
        orElse: () => Shop(
          id: widget.sourceId,
          name: 'Nguồn #${widget.sourceId}',
        ),
      );
    }
    final fav = await _favorites.isFavorite(FavoriteKind.source, widget.sourceId);
    if (!mounted) return;
    setState(() {
      _source = shop;
      _favorite = fav;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final added = await _favorites.toggle(FavoriteKind.source, widget.sourceId);
    if (!mounted) return;
    setState(() => _favorite = added);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          added ? 'Đã theo dõi nguồn này' : 'Đã bỏ theo dõi nguồn này',
        ),
      ),
    );
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final canLaunch = await canLaunchUrlString(url);
    if (!canLaunch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không mở được: $url')),
      );
      return;
    }
    await launchUrlString(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nguồn'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            IconButton(
              icon: Icon(_favorite ? Icons.bookmark : Icons.bookmark_border),
              tooltip: _favorite ? 'Đang theo dõi' : 'Theo dõi nguồn này',
              onPressed: _toggleFavorite,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mã giảm giá'),
              Tab(text: 'Sản phẩm'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _source == null
                ? const Center(child: Text('Không tìm thấy nguồn này'))
                : TabBarView(
                    children: [
                      _CouponsTab(
                        source: _source!,
                        couponRepo: _couponRepo,
                      ),
                      _ProductsTab(
                        source: _source!,
                        productRepo: _productRepo,
                      ),
                    ],
                  ),
        bottomNavigationBar: _source == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _source!.logoUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(_source!.logoUrl!),
                              )
                            : const CircleAvatar(child: Icon(Icons.storefront)),
                        title: Text(
                          _source!.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(_source!.description ?? 'Không có mô tả'),
                      ),
                      Row(
                        children: [
                          if (_source!.websiteUrl != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _openWebsite(_source!.websiteUrl!),
                                icon: const Icon(Icons.public),
                                label: const Text('Mở website'),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _CouponsTab extends StatelessWidget {
  final Shop source;
  final CouponRepo couponRepo;
  const _CouponsTab({
    required this.source,
    required this.couponRepo,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PageResult<Coupon>>(
      future: couponRepo.list(page: 1, pageSize: 40, shopId: source.id),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => (context as Element).markNeedsBuild(),
                child: const Text('Thử lại'),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        }
        final coupons = snapshot.data!.data;
        if (coupons.isEmpty) {
          return const Center(child: Text('Chưa có mã cho nguồn này'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, index) => CouponListItem(
            coupon: coupons[index],
          ),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: coupons.length,
        );
      },
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final Shop source;
  final ProductRepo productRepo;
  const _ProductsTab({
    required this.source,
    required this.productRepo,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PageResult<Product>>(
      future: productRepo.list(page: 1, pageSize: 20, shopId: source.id),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => (context as Element).markNeedsBuild(),
                child: const Text('Thử lại'),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!.data;
        if (items.isEmpty) {
          return const Center(child: Text('Chưa có sản phẩm'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: .62,
          ),
          itemBuilder: (_, index) => ProductGridCard(
            product: items[index],
          ),
          itemCount: items.length,
        );
      },
    );
  }
}
