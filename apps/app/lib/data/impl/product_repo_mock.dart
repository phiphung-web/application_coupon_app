import 'dart:math';
import '../../models/product.dart';

class ProductRepoMock {
  static final _rnd = Random();

  static final List<Product> _data = List.generate(48, (i) {
    final base = 99000 + _rnd.nextInt(400000);
    final original = base + (base * (10 + _rnd.nextInt(26)) ~/ 100);
    final pct = (100 - (base * 100 / original)).round();
    return Product(
      id: i + 1,
      name: 'Sản phẩm #${i + 1}',
      imageUrl: 'https://picsum.photos/seed/p${i + 1}/600/400',
      basePrice: base.toDouble(),
      originalPrice: original.toDouble(),
      discountPercent: pct.toDouble(),
      categoryId: (i % 6) + 1,
      shopId: ['shopee', 'lazada', 'tiki'][i % 3],
      description: 'Mô tả demo sản phẩm #${i + 1}',
      isHot: i % 4 == 0,
      bestCoupon: null, // detail sẽ tự tính từ CouponRepoMock
    );
  });

  Future<List<Product>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
    String? sort,
    String? shopId,
  }) async {
    var list = [..._data];
    if (categoryId != null) list = list.where((e) => e.categoryId == categoryId).toList();
    if (shopId != null) list = list.where((e) => e.shopId == shopId).toList();
    if (q != null && q.isNotEmpty) list = list.where((e) => e.name.toLowerCase().contains(q.toLowerCase())).toList();

    switch (sort) {
      case 'priceAsc':
        list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
        break;
      case 'priceDesc':
        list.sort((a, b) => b.basePrice.compareTo(a.basePrice));
        break;
      case 'discountDesc':
        list.sort((a, b) => (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0));
        break;
      case 'hot':
        list.sort((a, b) => (b.isHot ? 1 : 0).compareTo(a.isHot ? 1 : 0));
        break;
      default:
        list.sort((a, b) => b.id.compareTo(a.id));
    }

    final start = (page - 1) * pageSize;
    final end = min(start + pageSize, list.length);
    return start >= list.length ? [] : list.sublist(start, end);
  }

  Future<List<Product>> hot({int limit = 8}) async {
    final list = _data.where((e) => e.isHot).toList();
    list.sort((a, b) => (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0));
    return list.take(limit).toList();
  }

  Future<Product?> getById(int id) async {
    try {
      return _data.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
