import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/impl/product_repo_remote.dart';
import '../../data/impl/shop_repo_remote.dart';
import '../../data/repo/product_repo.dart';
import '../../data/repo/shop_repo.dart';
import '../../models/product.dart';
import '../../models/shop.dart';
import '../../services/favorites_service.dart';
import '../detail/product_detail_screen.dart';
import '../detail/source_detail_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FavoritesService _favorites = FavoritesService.instance;
  final ProductRepo _productRepo = ProductRepoRemote();
  final ShopRepo _shopRepo = ShopRepoRemote();

  List<Product> _favoriteProducts = const [];
  List<Shop> _favoriteSources = const [];
  bool _loading = true;

  StreamSubscription<Set<String>>? _itemSub;
  StreamSubscription<Set<String>>? _sourceSub;

  @override
  void initState() {
    super.initState();
    _hydrate();
    _itemSub = _favorites.watch(FavoriteKind.item).listen((_) => _hydrate());
    _sourceSub = _favorites.watch(FavoriteKind.source).listen((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    setState(() => _loading = true);
    final itemKeys = await _favorites.all(FavoriteKind.item);
    final sourceKeys = await _favorites.all(FavoriteKind.source);

    final itemIds = itemKeys.map((k) => k.split('_').last).where((s) => s.isNotEmpty).toList();
    final sourceIds = sourceKeys.map((k) => k.split('_').last).where((s) => s.isNotEmpty).toList();

    final products = await Future.wait(
      itemIds.map((id) async {
        final pid = int.tryParse(id);
        if (pid == null) return null;
        return await _productRepo.getById(pid);
      }),
    );
    final shops = await _shopRepo.list();
    final selectedShops = shops.where((shop) => sourceIds.contains(shop.id)).toList();

    if (!mounted) return;
    setState(() {
      _favoriteProducts = products.whereType<Product>().toList();
      _favoriteSources = selectedShops;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _itemSub?.cancel();
    _sourceSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: const Text('Khách hàng thân thiết'),
          subtitle: const Text('Cập nhật tính năng đăng nhập sau'),
        ),
        const SizedBox(height: 16),
        const Text('Sản phẩm yêu thích', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (_favoriteProducts.isEmpty)
          const Text('Chưa có sản phẩm nào được yêu thích.')
        else
          ..._favoriteProducts.map(
            (p) => Card(
              child: ListTile(
                leading: p.imageUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(p.imageUrl!))
                    : const CircleAvatar(child: Icon(Icons.image)),
                title: Text(p.name),
                subtitle: Text(p.sourceName ?? 'Nhiều nguồn'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: p.id),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        const Text('Nguồn yêu thích', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (_favoriteSources.isEmpty)
          const Text('Bạn chưa theo dõi nguồn nào.')
        else
          ..._favoriteSources.map(
            (shop) => Card(
              child: ListTile(
                leading: shop.logoUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(shop.logoUrl!))
                    : const CircleAvatar(child: Icon(Icons.storefront)),
                title: Text(shop.name),
                subtitle: Text(shop.description ?? 'Không có mô tả'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SourceDetailScreen(
                      sourceId: shop.id,
                      initial: shop,
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Đăng xuất'),
          subtitle: const Text('Tính năng sẽ sớm ra mắt'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          },
        ),
      ],
    );
  }
}
