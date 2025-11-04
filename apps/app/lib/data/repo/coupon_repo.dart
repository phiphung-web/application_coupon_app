import '../../core/result.dart';
import '../../models/coupon.dart';

abstract class CouponRepo {
  Future<List<Coupon>> hot({int limit = 8});
  Future<PageResult<Coupon>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
  });
  Future<Coupon?> getById(int id);
}
