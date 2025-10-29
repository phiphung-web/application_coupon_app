import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/category.dart';

class CategoryRepoMock {
  Future<List<Category>> list() async {
    final raw = await rootBundle.loadString('assets/json/categories.json');
    final list =
        (jsonDecode(raw) as List).map((e) => Category.fromJson(e)).toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }
}
