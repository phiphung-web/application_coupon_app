import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesLocal {
  FavoritesLocal(this._storageKey);

  final String _storageKey;
  final _ctrl = StreamController<Set<String>>.broadcast();

  Stream<Set<String>> watch() => _ctrl.stream;

  Future<Set<String>> _read(SharedPreferences sp) async {
    return (sp.getStringList(_storageKey) ?? const []).toSet();
  }

  Future<Set<String>> getAll() async {
    final sp = await SharedPreferences.getInstance();
    return _read(sp);
  }

  Future<bool> toggle(String id) async {
    final sp = await SharedPreferences.getInstance();
    final set = await _read(sp);
    final added = !set.contains(id);
    if (added) {
      set.add(id);
    } else {
      set.remove(id);
    }
    await sp.setStringList(_storageKey, set.toList());
    _ctrl.add(set);
    return added;
  }

  Future<bool> has(String id) async {
    final set = await getAll();
    return set.contains(id);
  }

  void dispose() {
    _ctrl.close();
  }
}
