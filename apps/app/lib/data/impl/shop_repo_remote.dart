import 'package:flutter/foundation.dart' show debugPrint;

import '../../models/shop.dart';
import '../repo/shop_repo.dart';
import '../../services/api_client.dart';
import 'shop_repo_mock.dart';

class ShopRepoRemote implements ShopRepo {
  ShopRepoRemote({
    ApiClient? apiClient,
    ShopRepo? fallback,
  })  : _api = apiClient ?? ApiClient(),
        _fallback = fallback ?? ShopRepoMock();

  final ApiClient _api;
  final ShopRepo _fallback;

  @override
  Future<List<Shop>> list() async {
    try {
      final json = await _api.get('sources');
      final List<dynamic> items;
      if (json is List) {
        items = json;
      } else if (json is Map && json['items'] is List) {
        items = json['items'] as List<dynamic>;
      } else {
        items = const [];
      }
      final result = items
          .map((e) => Shop.fromJson(e as Map<String, dynamic>))
          .toList();
      result.sort(
        (a, b) => b.priority.compareTo(a.priority),
      );
      return result;
    } catch (e) {
      debugPrint('ShopRepoRemote.list fallback: $e');
      return _fallback.list();
    }
  }
}
