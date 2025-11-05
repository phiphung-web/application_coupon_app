import 'dart:math';
import '../../core/result.dart';
import '../../models/product.dart';
import '../repo/product_repo.dart';

class ProductRepoMock implements ProductRepo {
  final _rnd = Random(11);
  final List<Product> _all = [];

  static const _types = [
    'Accessory',
    'Shoes',
    'Bag',
    'Gadget',
    'Cosmetic',
    'Outfit',
    'Kitchen',
    'Audio',
    'Smart Home',
    'Cleaning',
  ];
  static const _shops = [
    {'id': 'shopee', 'name': 'Shopee'},
    {'id': 'lazada', 'name': 'Lazada'},
    {'id': 'tiki', 'name': 'Tiki'},
    {'id': 'amazon', 'name': 'Amazon'},
  ];
  static const _badges = ['Top Pick', 'Amazon\'s Choice', 'HOT', null];

  ProductRepoMock() {
    for (int i = 0; i < 180; i++) {
      final base = [
        99000,
        149000,
        199000,
        299000,
        399000,
        499000,
        799000,
      ][_rnd.nextInt(7)];
      final hasSale = _rnd.nextBool();
      final salePct = [0, 10, 15, 20, 30, 40, 50, 70][_rnd.nextInt(8)];
      final sale = hasSale ? (base - (base * salePct ~/ 100)) : null;
      final shop = _shops[_rnd.nextInt(_shops.length)];
      final bIndex = _rnd.nextInt(_badges.length);

      _all.add(
        Product(
          id: i + 1,
          name: 'Sản phẩm #${i + 1}',
          imageUrl: 'https://picsum.photos/seed/p$i/640/640',
          basePrice: base,
          originalPrice: orig,
          finalPrice: sale,
          categoryId: _rnd.nextInt(10) + 1,
          type: _types[_rnd.nextInt(_types.length)],
          shopId: shop['id'] as String?,
          shopName: shop['name'] as String?,
          badge: _badges[bIndex],
        ),
      );
    }
  }

  @override
  Future<List<Product>> hot({int limit = 8}) async {
    // lấy theo % OFF cao nhất
    final list = [..._all]
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    return list.take(limit).toList();
  }

  @override
  Future<PageResult<Product>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
  }) async {
    var data = _all;
    if (categoryId != null) {
      data = data.where((p) => p.categoryId == categoryId).toList();
    }
    if (q != null && q.isNotEmpty) {
      final qq = q.toLowerCase();
      data = data.where((p) => p.name.toLowerCase().contains(qq)).toList();
    }
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final slice = start >= data.length
        ? <Product>[]
        : data.sublist(start, end > data.length ? data.length : end);
    final hasMore = end < data.length;
    return PageResult(data: slice, hasMore: hasMore, nextPage: page + 1);
  }

  @override
  Future<Product?> getById(int id) async {
    try {
      return _all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
