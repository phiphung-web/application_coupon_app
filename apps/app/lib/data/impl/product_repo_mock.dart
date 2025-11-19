import 'dart:math';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../core/result.dart';
import '../../models/badge.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../repo/product_repo.dart';

class ProductRepoMock implements ProductRepo {
  static final _rnd = Random(42);

  static final _categories = List<Category>.generate(
    8,
    (i) => Category(
      id: i + 1,
      name: 'Danh mục ${i + 1}',
      imageUrl: 'https://picsum.photos/seed/cat${i + 1}/200/200',
    ),
  );

  static final _badges = <Badge>[
    const Badge(id: 1, key: 'HOT', label: 'Hot', priority: 90),
    const Badge(id: 2, key: 'FLASH', label: 'Flash Sale', priority: 70),
  ];

  static final List<Product> _data = List.generate(60, (index) {
    final cat = _categories[index % _categories.length];
    final badgeList = <Badge>[];
    if (index % 4 == 0) badgeList.add(_badges.first);
    if (index % 6 == 0) badgeList.add(_badges.last);

    final original = 500000 + _rnd.nextInt(500000);
    final current = original - (original * (_rnd.nextInt(30) + 5) ~/ 100);

    return Product(
      id: index + 1,
      name: 'Sản phẩm #${index + 1}',
      imageUrl: 'https://picsum.photos/seed/p${index + 1}/600/400',
      priceOriginal: original,
      priceCurrent: current,
      currency: 'VND',
      description: 'Mô tả demo cho sản phẩm #${index + 1}',
      sourceId: ['shopee', 'lazada', 'tiki'][index % 3],
      categories: [cat],
      badges: badgeList,
    );
  });

  @override
  Future<PageResult<Product>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
    String? sort,
    String? shopId,
  }) async {
    var list = [..._data];
    if (categoryId != null) {
      list = list
          .where((p) =>
              p.categories.any((cat) => cat.id == categoryId))
          .toList();
    }
    if (shopId != null && shopId.isNotEmpty) {
      list = list.where((p) => p.sourceId == shopId).toList();
    }
    if (q != null && q.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
          .toList();
    }

    switch (sort) {
      case 'priceAsc':
      case 'price_asc':
        list.sort((a, b) => a.priceEffective.compareTo(b.priceEffective));
        break;
      case 'priceDesc':
      case 'price_desc':
        list.sort((a, b) => b.priceEffective.compareTo(a.priceEffective));
        break;
      case 'discountDesc':
      case 'discount_desc':
        list.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;
      case 'hot':
        list.sort((a, b) => (b.isHot ? 1 : 0) - (a.isHot ? 1 : 0));
        break;
      default:
        list.sort((a, b) => b.id.compareTo(a.id));
    }

    final start = (page - 1) * pageSize;
    final end = min(start + pageSize, list.length);
    final meta = {'page': page, 'limit': pageSize, 'total': list.length};
    if (start >= list.length) {
      return PageResult(
        data: const [],
        hasMore: false,
        nextPage: page,
        meta: meta,
      );
    }
    final slice = list.sublist(start, end);
    final hasMore = end < list.length;
    return PageResult(
      data: slice,
      hasMore: hasMore,
      nextPage: hasMore ? page + 1 : page,
      meta: meta,
    );
  }

  @override
  Future<List<Product>> hot({int limit = 8}) async {
    final list = _data.where((p) => p.isHot).toList();
    list.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    return list.take(limit).toList();
  }

  @override
  Future<Product?> getById(int id) async {
    try {
      return _data.firstWhere((p) => p.id == id);
    } catch (_) {
      debugPrint('ProductRepoMock.getById missing id=$id');
      return null;
    }
  }
}
