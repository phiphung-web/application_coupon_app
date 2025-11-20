import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefsService {
  NotificationPrefsService._();

  static final NotificationPrefsService instance = NotificationPrefsService._();

  static const _itemKey = 'notify_item_ids';
  static const _sourceKey = 'notify_source_ids';
  static const _seenCouponsKey = 'notify_seen_coupons';
  static const _systemKey = 'notify_system_enabled';
  static const _eventKey = 'notify_event_enabled';
  static const _personalKey = 'notify_personal_enabled';

  Future<Set<String>> _read(String key) async {
    final sp = await SharedPreferences.getInstance();
    return (sp.getStringList(key) ?? const []).toSet();
  }

  Future<void> _write(String key, Set<String> values) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(key, values.toList());
  }

  Future<bool> _readBool(String key, bool fallback) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(key) ?? fallback;
  }

  Future<void> _writeBool(String key, bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(key, value);
  }

  Future<bool> toggleItem(int id) async {
    final key = id.toString();
    final items = await _read(_itemKey);
    final added = items.add(key);
    if (!added) {
      items.remove(key);
    }
    await _write(_itemKey, items);
    return added;
  }

  Future<bool> toggleSource(String id) async {
    final sources = await _read(_sourceKey);
    final added = sources.add(id);
    if (!added) {
      sources.remove(id);
    }
    await _write(_sourceKey, sources);
    return added;
  }

  Future<Set<int>> itemIds() async {
    final raw = await _read(_itemKey);
    return raw.map(int.parse).toSet();
  }

  Future<Set<String>> sourceIds() => _read(_sourceKey);

  Future<bool> isItemEnabled(int id) async {
    final ids = await itemIds();
    return ids.contains(id);
  }

  Future<bool> isSourceEnabled(String id) async {
    final ids = await sourceIds();
    return ids.contains(id);
  }

  Future<bool> isSystemEnabled() => _readBool(_systemKey, true);
  Future<bool> isEventEnabled() => _readBool(_eventKey, true);
  Future<bool> isPersonalEnabled() => _readBool(_personalKey, true);

  Future<void> setSystemEnabled(bool value) => _writeBool(_systemKey, value);
  Future<void> setEventEnabled(bool value) => _writeBool(_eventKey, value);
  Future<void> setPersonalEnabled(bool value) => _writeBool(_personalKey, value);

  Future<void> markCouponSeen(int couponId) async {
    final set = await _read(_seenCouponsKey);
    set.add(couponId.toString());
    await _write(_seenCouponsKey, set);
  }

  Future<bool> hasSeenCoupon(int couponId) async {
    final set = await _read(_seenCouponsKey);
    return set.contains(couponId.toString());
  }
}
