import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryLocal {
  static const _k = 'search_history';
  Future<List<String>> get() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_k) ?? const [];
  }

  Future<void> add(String q, {int limit = 10}) async {
    if (q.trim().isEmpty) return;
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_k) ?? [];
    list.removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    list.insert(0, q);
    if (list.length > limit) list.removeRange(limit, list.length);
    await sp.setStringList(_k, list);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_k);
  }
}
