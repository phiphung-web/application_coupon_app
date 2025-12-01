import 'package:flutter/foundation.dart' show debugPrint;

import '../../models/category.dart';
import '../repo/category_repo.dart';
import '../../services/api_client.dart';
import 'category_repo_mock.dart';

class CategoryRepoRemote implements CategoryRepo {
  CategoryRepoRemote({
    ApiClient? apiClient,
    CategoryRepo? fallback,
  })  : _api = apiClient ?? ApiClient(),
        _fallback = fallback ?? CategoryRepoMock();

  final ApiClient _api;
  final CategoryRepo _fallback;

  @override
  Future<List<Category>> list() async {
    try {
      final json = await _api.get('categories/all', query: {'active': 'true'});
      if (json is List) {
        return json
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (json is Map && json['items'] is List) {
        return (json['items'] as List)
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('CategoryRepoRemote.list fallback: $e');
      return _fallback.list();
    }
  }
}
