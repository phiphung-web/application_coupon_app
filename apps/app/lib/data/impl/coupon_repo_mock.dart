import 'dart:math';
import '../../core/result.dart';
import '../../models/coupon.dart';
import '../repo/coupon_repo.dart';

class CouponRepoMock implements CouponRepo {
  final _rnd = Random(3);
  final List<Coupon> _all = [];

  CouponRepoMock() {
    for (int i = 0; i < 160; i++) {
      final isPercent = _rnd.nextBool();
      final value = isPercent
          ? [10, 15, 20, 30, 40, 50, 70][_rnd.nextInt(7)]
          : [10000, 20000, 30000, 50000, 80000][_rnd.nextInt(5)];
      final maxDiscount = isPercent
          ? [null, 30000, 50000, 80000, 120000][_rnd.nextInt(5)]
          : value;

      _all.add(
        Coupon(
          id: i + 1,
          title: 'Ưu đãi ${isPercent ? "$value%" : "${value ~/ 1000}k"}',
          code: 'CODE${100 + i}',
          shopId: _rnd.nextInt(4) + 1,
          categoryId: _rnd.nextInt(10) + 1,
          categoryIds: const [],
          applicableTypes: ([
            'Accessory',
            'Shoes',
            'Bag',
            'Gadget',
            'Cosmetic',
            'Outfit',
            'Kitchen',
            'Audio',
            'Smart Home',
            'Cleaning',
          ]..shuffle(_rnd)).take(3).toList(),
          discountType: isPercent ? DiscountType.percent : DiscountType.fixed,
          discountValue: value,
          maxDiscount: maxDiscount,
          minOrder: [null, 99000, 199000, 299000][_rnd.nextInt(4)],
          endAt: DateTime.now().add(Duration(days: _rnd.nextInt(20) - 5)),
          isHot: _rnd.nextDouble() < .25,
          priority: 50 + _rnd.nextInt(50),
          tags: _rnd.nextDouble() < .25 ? const ['hot'] : const [],
          imageUrl: 'https://picsum.photos/seed/c$i/640/360',
          trackingLink: 'https://example.com/promo/$i',
          deeplink: null,
          terms: const [
            'Không cộng dồn chương trình khác',
            'Áp dụng cho mặt hàng chỉ định',
          ],
        ),
      );
    }
  }

  @override
  Future<List<Coupon>> hot({int limit = 8}) async =>
      _all.where((c) => c.isHot || c.priority >= 80).take(limit).toList();

  @override
  Future<PageResult<Coupon>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
  }) async {
    var data = _all;
    if (categoryId != null)
      data = data
          .where(
            (c) =>
                c.categoryId == categoryId ||
                c.categoryIds.contains(categoryId),
          )
          .toList();
    if (q != null && q.isNotEmpty)
      data = data
          .where(
            (c) =>
                c.title.toLowerCase().contains(q.toLowerCase()) ||
                c.code.toLowerCase().contains(q.toLowerCase()),
          )
          .toList();
    data.sort((a, b) => (b.priority).compareTo(a.priority));
    final start = (page - 1) * pageSize, end = start + pageSize;
    final slice = start >= data.length
        ? <Coupon>[]
        : data.sublist(start, end > data.length ? data.length : end);
    final hasMore = end < data.length;
    return PageResult(data: slice, hasMore: hasMore, nextPage: page + 1);
  }

  @override
  Future<Coupon?> getById(int id) async => _all.firstWhere((e) => e.id == id);
}
