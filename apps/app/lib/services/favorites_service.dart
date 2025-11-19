import '../data/impl/favorites_local.dart';

enum FavoriteKind { item, source, coupon }

class FavoritesService {
  FavoritesService._()
      : _items = FavoritesLocal('favorite_item_ids'),
        _sources = FavoritesLocal('favorite_source_ids'),
        _coupons = FavoritesLocal('favorite_coupon_ids');

  static final FavoritesService instance = FavoritesService._();

  final FavoritesLocal _items;
  final FavoritesLocal _sources;
  final FavoritesLocal _coupons;

  // Helpers
  FavoritesLocal _store(FavoriteKind kind) {
    switch (kind) {
      case FavoriteKind.item:
        return _items;
      case FavoriteKind.source:
        return _sources;
      case FavoriteKind.coupon:
        return _coupons;
    }
  }

  String _key(FavoriteKind kind, String rawId) {
    return '${kind.name}_$rawId';
  }

  Future<bool> toggle(FavoriteKind kind, String rawId) {
    return _store(kind).toggle(_key(kind, rawId));
  }

  Future<bool> isFavorite(FavoriteKind kind, String rawId) {
    return _store(kind).has(_key(kind, rawId));
  }

  Stream<Set<String>> watch(FavoriteKind kind) {
    return _store(kind).watch();
  }

  Future<Set<String>> all(FavoriteKind kind) {
    return _store(kind).getAll();
  }
}
