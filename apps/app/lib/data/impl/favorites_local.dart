import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesLocal {
  static const _k = 'favorites_ids';
  final _ctrl = StreamController<Set<String>>.broadcast();

  Stream<Set<String>> watch() => _ctrl.stream;

  Future<Set<String>> getAll() async {
    final sp = await SharedPreferences.getInstance();
    return (sp.getStringList(_k) ?? const []).toSet();
  }

  Future<void> toggle(String id) async {
    final sp = await SharedPreferences.getInstance();
    final set = (sp.getStringList(_k) ?? const []).toSet();
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    await sp.setStringList(_k, set.toList());
    _ctrl.add(set);
  }

  Future<bool> has(String id) async {
    final set = await getAll();
    return set.contains(id);
  }

  void dispose() {
    _ctrl.close();
  }
}
