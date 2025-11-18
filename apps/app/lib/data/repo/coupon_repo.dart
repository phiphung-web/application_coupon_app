import '../../core/result.dart';
import '../../models/coupon.dart';

abstract class CouponRepo {
  Future<PageResult<Coupon>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
    String? sort,
    String? shopId,
    String? badgeKey,
  });

  Future<List<Coupon>> hot({int limit = 10});
  Future<Coupon?> getById(int id);
}
