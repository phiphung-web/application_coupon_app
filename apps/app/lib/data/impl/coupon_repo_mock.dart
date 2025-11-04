import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/coupon.dart';

class CouponRepoMock {
  /// sort: 'endAtAsc' | 'priorityDesc' | null
  Future<List<Coupon>> list({
    int page = 1,
    int limit = 20,
    String? q,
    String? shopId,
    String? categoryId,
    String? sort,
  }) async {
    final raw = await rootBundle.loadString('assets/json/coupons.json');
    final list =
        (jsonDecode(raw) as List).map((e) => Coupon.fromJson(e)).toList();

    Iterable<Coupon> data = list;

    if (q != null && q.trim().isNotEmpty) {
      final lower = q.toLowerCase();
      data = data.where((c) =>
          c.title.toLowerCase().contains(lower) ||
          c.code.toLowerCase().contains(lower) ||
          c.shopId.toLowerCase().contains(lower));
    }

    if (shopId != null && shopId.isNotEmpty) {
      data = data.where((c) => c.shopId == shopId);
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      data = data.where((c) => c.categoryIds.contains(categoryId));
    }

    if (sort == 'endAtAsc') {
      final tmp = data.toList()..sort((a, b) => a.endAt.compareTo(b.endAt));
      data = tmp;
    } else if (sort == 'priorityDesc') {
      final tmp = data.toList()
        ..sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
      data = tmp;
    }

    return data.skip((page - 1) * limit).take(limit).toList();
  }

  Future<Coupon> getById(String id) async {
    final raw = await rootBundle.loadString('assets/json/coupons.json');
    final list =
        (jsonDecode(raw) as List).map((e) => Coupon.fromJson(e)).toList();
    return list.firstWhere((c) => c.id == id);
  }
}
