import 'package:flutter/foundation.dart' show debugPrint;

import '../../core/result.dart';
import '../../models/product.dart';
import '../repo/product_repo.dart';
import '../../services/api_client.dart';
import 'product_repo_mock.dart';

class ProductRepoRemote implements ProductRepo {
  ProductRepoRemote({
    ApiClient? apiClient,
    ProductRepo? fallback,
  })  : _api = apiClient ?? ApiClient(),
        _fallback = fallback ?? ProductRepoMock();

  final ApiClient _api;
  final ProductRepo _fallback;

  List<Map<String, dynamic>> _parseItems(dynamic json) {
    final raw =
        json is List ? json : (json is Map<String, dynamic> ? json['items'] : null);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return const [];
  }

  Map<String, dynamic>? _parseMeta(dynamic json) {
    if (json is Map<String, dynamic> && json['meta'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(json['meta'] as Map<String, dynamic>);
    }
    return null;
  }

  Map<String, dynamic> _meta(
    Map<String, dynamic>? raw,
    int fallbackPage,
    int fallbackLimit,
    int total,
  ) {
    final page = raw != null && raw['page'] is int ? raw['page'] as int : fallbackPage;
    final limit = raw != null && raw['limit'] is int ? raw['limit'] as int : fallbackLimit;
    final meta = {
      'page': page,
      'limit': limit,
      'total': raw != null && raw['total'] is int ? raw['total'] as int : total,
    };
    return meta;
  }

  @override
  Future<PageResult<Product>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
    String? sort,
    String? shopId,
    String? itemType,
    int? minPrice,
    int? maxPrice,
    bool? hasCoupon,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': pageSize,
      'withDeal': 'true',
      if (categoryId != null) 'cat': categoryId,
      if (q != null && q.isNotEmpty) 'q': q,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
      if (shopId != null && shopId.isNotEmpty) 'source': shopId,
      if (itemType != null && itemType.isNotEmpty) 'itemType': itemType,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (hasCoupon != null) 'hasCoupon': hasCoupon,
    };
    try {
      final response = await _api.get('products', query: query);
      final items = _parseItems(response)
          .map((e) => Product.fromJson(e))
          .toList();
      final metaRaw = _parseMeta(response);
      final totalFromMeta =
          metaRaw != null && metaRaw['total'] is int ? metaRaw['total'] as int : items.length;
      final meta = _meta(metaRaw, page, pageSize, totalFromMeta);
      final currentPage = meta['page'] as int;
      final limit = meta['limit'] as int;
      final total = meta['total'] as int;
      final hasMore = currentPage * limit < total;
      return PageResult(
        data: items,
        hasMore: hasMore,
        nextPage: hasMore ? currentPage + 1 : currentPage,
        meta: meta,
      );
    } catch (e) {
      debugPrint('ProductRepoRemote.list fallback: $e');
      final fallback = await _fallback.list(
        page: page,
        pageSize: pageSize,
        categoryId: categoryId,
        q: q,
        sort: sort,
        shopId: shopId,
      );
      return fallback.copyWith(fromFallback: true);
    }
  }

  @override
  Future<List<Product>> hot({int limit = 8}) async {
    try {
      final response = await _api.get('products', query: {
        'limit': limit,
        'withDeal': 'true',
        'sort': 'hot',
      });
      final items = _parseItems(response)
          .map((e) => Product.fromJson(e))
          .toList();
      return items.take(limit).toList();
    } catch (e) {
      debugPrint('ProductRepoRemote.hot fallback: $e');
      return _fallback.hot(limit: limit);
    }
  }

  @override
  Future<Product?> getById(int id) async {
    try {
      final json = await _api.get('products/$id', query: {'withDeal': 'true'});
      if (json is Map<String, dynamic>) {
        return Product.fromJson(json);
      }
      if (json is List && json.isNotEmpty && json.first is Map) {
        return Product.fromJson(
          Map<String, dynamic>.from(json.first as Map),
        );
      }
      return null;
    } catch (e) {
      debugPrint('ProductRepoRemote.getById fallback: $e');
      return _fallback.getById(id);
    }
  }
}
