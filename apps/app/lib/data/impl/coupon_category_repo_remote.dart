import 'package:flutter/foundation.dart' show debugPrint;

import '../../models/coupon_category.dart';
import '../repo/coupon_category_repo.dart';
import '../../services/api_client.dart';

class CouponCategoryRepoRemote implements CouponCategoryRepo {
  CouponCategoryRepoRemote({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  @override
  Future<List<CouponCategory>> list() async {
    try {
      final json = await _api.get('coupon-categories');
      final list = (json is List ? json : (json is Map ? json['items'] : null)) ?? const [];
      return List<Map<String, dynamic>>.from(list as List)
          .map(CouponCategory.fromJson)
          .toList();
    } catch (e) {
      debugPrint('CouponCategoryRepoRemote.list error: $e');
      return const [];
    }
  }

  @override
  Future<List<CouponCategory>> highlights({int limit = 6}) async {
    try {
      final json = await _api.get('coupon-categories/highlights', query: {'limit': limit});
      final list = json is List ? json : (json is Map ? json['items'] : null);
      if (list is List) {
        return list.map((e) => CouponCategory.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
      return const [];
    } catch (e) {
      debugPrint('CouponCategoryRepoRemote.highlights error: $e');
      return const [];
    }
  }
}

