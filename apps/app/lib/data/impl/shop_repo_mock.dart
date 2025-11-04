import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/shop.dart';

class ShopRepoMock {
  Future<List<Shop>> list() async {
    final raw = await rootBundle.loadString('assets/json/shops.json');
    final data = jsonDecode(raw);
    final list = (data as List)
        .map((e) => Shop.fromJson(e as Map<String, dynamic>))
        .toList();

    // sort theo priority giảm dần; nếu bằng nhau thì theo name
    list.sort((a, b) {
      final cmp = b.priority.compareTo(a.priority);
      return (cmp != 0) ? cmp : a.name.compareTo(b.name);
    });
    return list;
  }
}
