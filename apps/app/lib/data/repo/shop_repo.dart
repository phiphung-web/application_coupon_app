import '../../models/shop.dart';

abstract class ShopRepo {
  Future<List<Shop>> list();
  Future<Shop?> get(String id);
}
