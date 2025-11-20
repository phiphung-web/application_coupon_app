import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/copy_history_entry.dart';

class CopyHistoryService {
  CopyHistoryService._();

  static final CopyHistoryService instance = CopyHistoryService._();

  static const _storageKey = 'copy_history_entries';

  Future<List<CopyHistoryEntry>> all() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_storageKey) ?? const [];
    return raw
        .map((entry) => CopyHistoryEntry.fromJson(jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  Future<void> record({
    required int couponId,
    required String code,
    required String title,
    int maxEntries = 20,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final items = await all();
    items.removeWhere((item) => item.couponId == couponId);
    items.insert(
      0,
      CopyHistoryEntry(
        couponId: couponId,
        code: code,
        title: title,
        copiedAt: DateTime.now(),
      ),
    );
    if (items.length > maxEntries) {
      items.removeRange(maxEntries, items.length);
    }
    await sp.setStringList(
      _storageKey,
      items.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}

