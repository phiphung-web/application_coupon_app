import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/coupon.dart';

class CouponRepoMock {
  Future<List<Coupon>> list({int page = 1, int limit = 20, String? q}) async {
    final raw = await rootBundle.loadString('assets/json/coupons.json');
    final list =
        (jsonDecode(raw) as List).map((e) => Coupon.fromJson(e)).toList();
    Iterable<Coupon> data = list;
    if (q != null && q.trim().isNotEmpty) {
      final lower = q.toLowerCase();
      data = data.where((c) =>
          c.title.toLowerCase().contains(lower) ||
          c.code.toLowerCase().contains(lower));
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
