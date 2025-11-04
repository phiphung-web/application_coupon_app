import 'dart:math';
import '../../core/result.dart';
import '../../models/product.dart';
import '../repo/product_repo.dart';

class ProductRepoMock implements ProductRepo {
  final _rnd = Random(7);
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
  final List<Product> _all = [];

  ProductRepoMock() {
    for (int i = 0; i < 120; i++) {
      final price = [
        99000,
        149000,
        199000,
        299000,
        399000,
        499000,
        799000,
      ][_rnd.nextInt(7)];
      _all.add(
        Product(
          id: i + 1,
          name: 'Sản phẩm #${i + 1}',
          imageUrl: 'https://picsum.photos/seed/p$i/640/360',
          basePrice: price,
          categoryId: _rnd.nextInt(10) + 1,
          type: _types[_rnd.nextInt(_types.length)],
          shopId: _rnd.nextInt(4) + 1,
          source: ['Shopee', 'Lazada', 'Tiki', 'Amazon'][_rnd.nextInt(4)],
        ),
      );
    }
  }

  @override
  Future<List<Product>> hot({int limit = 8}) async => _all.take(limit).toList();

  @override
  Future<PageResult<Product>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
  }) async {
    var data = _all;
    if (categoryId != null)
      data = data.where((p) => p.categoryId == categoryId).toList();
    if (q != null && q.isNotEmpty)
      data = data
          .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
          .toList();
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final slice = start >= data.length
        ? <Product>[]
        : data.sublist(start, end > data.length ? data.length : end);
    final hasMore = end < data.length;
    return PageResult(data: slice, hasMore: hasMore, nextPage: page + 1);
  }

  @override
  Future<Product?> getById(int id) async => _all.firstWhere((e) => e.id == id);
}
