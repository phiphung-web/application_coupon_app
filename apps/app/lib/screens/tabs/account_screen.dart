import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/impl/product_repo_remote.dart';
import '../../data/impl/shop_repo_remote.dart';
import '../../data/repo/product_repo.dart';
import '../../data/repo/shop_repo.dart';
import '../../models/copy_history_entry.dart';
import '../../models/product.dart';
import '../../models/shop.dart';
import '../../services/copy_history_service.dart';
import '../../services/favorites_service.dart';
import '../../services/notification_prefs_service.dart';
import '../detail/product_detail_screen.dart';
import '../detail/source_detail_screen.dart';
import 'notification_settings_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FavoritesService _favorites = FavoritesService.instance;
  final NotificationPrefsService _prefs = NotificationPrefsService.instance;
  final ProductRepo _productRepo = ProductRepoRemote();
  final ShopRepo _shopRepo = ShopRepoRemote();

  List<Product> _favoriteProducts = const [];
  List<Shop> _favoriteSources = const [];
  List<CopyHistoryEntry> _history = const [];
  Set<int> _notifyItems = {};
  Set<String> _notifySources = {};
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

    final itemIds =
        itemKeys.map((k) => k.split('_').last).where((s) => s.isNotEmpty).toList();
    final sourceIds =
        sourceKeys.map((k) => k.split('_').last).where((s) => s.isNotEmpty).toList();

    final products = await Future.wait(
      itemIds.map((id) async {
        final pid = int.tryParse(id);
        if (pid == null) return null;
        return _productRepo.getById(pid);
      }),
    );
    final shops = await _shopRepo.list();
    final selectedShops = shops.where((shop) => sourceIds.contains(shop.id)).toList();
    final history = await CopyHistoryService.instance.all();
    final notifyItems = await _prefs.itemIds();
    final notifySources = await _prefs.sourceIds();

    if (!mounted) return;
    setState(() {
      _favoriteProducts = products.whereType<Product>().toList();
      _favoriteSources = selectedShops;
      _history = history;
      _notifyItems = notifyItems;
      _notifySources = notifySources;
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
        _buildProfileHeader(),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.tune),
          title: const Text('Quản lý thông báo'),
          subtitle: const Text('Chọn loại thông báo muốn nhận'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Sản phẩm yêu thích', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (_favoriteProducts.isEmpty)
          const Text('Chưa có sản phẩm nào được yêu thích.')
        else
          ..._favoriteProducts.map(_buildProductCard),
        const SizedBox(height: 24),
        const Text('Nguồn yêu thích', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (_favoriteSources.isEmpty)
          const Text('Bạn chưa theo dõi nguồn nào.')
        else
          ..._favoriteSources.map(_buildSourceCard),
        const SizedBox(height: 24),
        const Text('Lịch sử mã đã copy', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (_history.isEmpty)
          const Text('Bạn chưa copy mã nào gần đây.')
        else
          ..._history.map(_buildHistoryTile),
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

  Widget _buildProfileHeader() {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: const Text('Khách thân thiết'),
        subtitle: const Text('guest@coupon.app · Tham gia từ 01/2024'),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      child: ListTile(
        leading: product.imageUrl != null
            ? CircleAvatar(backgroundImage: NetworkImage(product.imageUrl!))
            : const CircleAvatar(child: Icon(Icons.image)),
        title: Text(product.name),
        subtitle: Text(product.sourceName ?? 'Nhiều nguồn'),
        trailing: Switch(
          value: _notifyItems.contains(product.id),
          onChanged: (_) => _toggleItemNotify(product.id),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceCard(Shop shop) {
    return Card(
      child: ListTile(
        leading: shop.logoUrl != null
            ? CircleAvatar(backgroundImage: NetworkImage(shop.logoUrl!))
            : const CircleAvatar(child: Icon(Icons.storefront)),
        title: Text(shop.name),
        subtitle: Text(shop.description ?? 'Không có mô tả'),
        trailing: Switch(
          value: _notifySources.contains(shop.id),
          onChanged: (_) => _toggleSourceNotify(shop.id),
        ),
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
    );
  }

  Widget _buildHistoryTile(CopyHistoryEntry entry) {
    final time =
        '${entry.copiedAt.hour.toString().padLeft(2, '0')}:${entry.copiedAt.minute.toString().padLeft(2, '0')}';
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(entry.title),
      subtitle: Text('Code ${entry.code} · $time'),
    );
  }

  Future<void> _toggleItemNotify(int id) async {
    final enabled = await _prefs.toggleItem(id);
    setState(() {
      if (enabled) {
        _notifyItems.add(id);
      } else {
        _notifyItems.remove(id);
      }
    });
  }

  Future<void> _toggleSourceNotify(String id) async {
    final enabled = await _prefs.toggleSource(id);
    setState(() {
      if (enabled) {
        _notifySources.add(id);
      } else {
        _notifySources.remove(id);
      }
    });
  }
}

