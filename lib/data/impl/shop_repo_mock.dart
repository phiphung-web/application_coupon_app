import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/shop.dart';

class ShopRepoMock {
  Future<List<Shop>> list() async {
    final raw = await rootBundle.loadString('assets/json/shops.json');
    final list =
        (jsonDecode(raw) as List).map((e) => Shop.fromJson(e)).toList();
    list.sort((a, b) => b.priority.compareTo(a.priority));
    return list;
  }
}
