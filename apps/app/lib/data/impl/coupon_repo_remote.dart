import 'package:flutter/foundation.dart' show debugPrint;

import '../../core/result.dart';
import '../../models/coupon.dart';
import '../repo/coupon_repo.dart';
import '../../services/api_client.dart';
import 'coupon_repo_mock.dart';

class CouponRepoRemote implements CouponRepo {
  CouponRepoRemote({
    ApiClient? apiClient,
    CouponRepo? fallback,
  })  : _api = apiClient ?? ApiClient(),
        _fallback = fallback ?? CouponRepoMock();

  final ApiClient _api;
  final CouponRepo _fallback;

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

  @override
  Future<PageResult<Coupon>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
    String? sort,
    String? shopId,
    String? badgeKey,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': pageSize,
      if (categoryId != null) 'cat': categoryId,
      if (q != null && q.isNotEmpty) 'q': q,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
      if (shopId != null && shopId.isNotEmpty) 'source': shopId,
      if (badgeKey != null && badgeKey.isNotEmpty) 'badge': badgeKey,
    };
    try {
      final response = await _api.get('coupons', query: query);
      final items = _parseItems(response)
          .map((e) => Coupon.fromJson(e))
          .toList();
      final metaRaw = _parseMeta(response);
      final currentPage =
          metaRaw != null && metaRaw['page'] is int ? metaRaw['page'] as int : page;
      final limit =
          metaRaw != null && metaRaw['limit'] is int ? metaRaw['limit'] as int : pageSize;
      final total = metaRaw != null && metaRaw['total'] is int
          ? metaRaw['total'] as int
          : items.length;
      final hasMore = currentPage * limit < total;
      return PageResult(
        data: items,
        hasMore: hasMore,
        nextPage: hasMore ? currentPage + 1 : currentPage,
        meta: {'page': currentPage, 'limit': limit, 'total': total},
      );
    } catch (e) {
      debugPrint('CouponRepoRemote.list fallback: $e');
      final fallback = await _fallback.list(
        page: page,
        pageSize: pageSize,
        categoryId: categoryId,
        q: q,
        sort: sort,
        shopId: shopId,
        badgeKey: badgeKey,
      );
      return fallback.copyWith(fromFallback: true);
    }
  }

  @override
  Future<List<Coupon>> hot({int limit = 10}) async {
    try {
      final response = await _api.get('coupons', query: {
        'limit': limit,
        'active': 'true',
        'sort': 'hot',
      });
      final items = _parseItems(response)
          .map((e) => Coupon.fromJson(e))
          .toList();
      return items.take(limit).toList();
    } catch (e) {
      debugPrint('CouponRepoRemote.hot fallback: $e');
      return _fallback.hot(limit: limit);
    }
  }

  @override
  Future<Coupon?> getById(int id) async {
    try {
      final json = await _api.get('coupons/$id');
      if (json is Map<String, dynamic>) {
        return Coupon.fromJson(json);
      }
      if (json is List && json.isNotEmpty && json.first is Map) {
        return Coupon.fromJson(
          Map<String, dynamic>.from(json.first as Map),
        );
      }
      return null;
    } catch (e) {
      debugPrint('CouponRepoRemote.getById fallback: $e');
      return _fallback.getById(id);
    }
  }
}
