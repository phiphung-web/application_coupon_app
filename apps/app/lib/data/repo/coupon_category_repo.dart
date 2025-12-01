import '../../models/coupon_category.dart';

abstract class CouponCategoryRepo {
  Future<List<CouponCategory>> list();
  Future<List<CouponCategory>> highlights({int limit});
}

