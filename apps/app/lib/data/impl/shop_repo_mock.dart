import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/shop.dart';
import '../repo/shop_repo.dart';

class ShopRepoMock implements ShopRepo {
  @override
  Future<List<Shop>> list() async {
    try {
      final raw = await rootBundle.loadString('assets/json/shop.json');
      final data = jsonDecode(raw);
      final list = (data as List)
          .map((e) => Shop.fromJson(e as Map<String, dynamic>))
          .toList();

      list.sort((a, b) {
        final cmp = b.priority.compareTo(a.priority);
        return (cmp != 0) ? cmp : a.name.compareTo(b.name);
      });
      return list;
    } catch (_) {
      return const [];
    }
  }
}