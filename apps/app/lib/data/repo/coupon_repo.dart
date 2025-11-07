import '../../models/coupon.dart';

abstract class CouponRepo {
  Future<List<Coupon>> list({
    int page,
    int pageSize,
    int? categoryId,
    String? q,
    String? sort,
    String? shopId,
  });

  Future<List<Coupon>> hot({int limit});
  Future<Coupon?> getById(String id);
}
