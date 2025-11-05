import 'dart:math';
import '../../core/result.dart';
import '../../models/coupon.dart';
import '../repo/coupon_repo.dart';

class CouponRepoMock implements CouponRepo {
  final _rnd = Random(7);
  final List<Coupon> _all = [];

  static const _types = [
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
  ];

  CouponRepoMock() {
    // Sinh 180 coupon giả lập
    for (int i = 0; i < 180; i++) {
      final isPercent = _rnd.nextBool();
      final discountValue = isPercent
          ? [10, 15, 20, 30, 40, 50, 70][_rnd.nextInt(7)]
          : [10000, 20000, 30000, 50000, 80000, 120000][_rnd.nextInt(6)];

      final maxDiscount = isPercent
          ? [null, 30000, 50000, 80000, 120000][_rnd.nextInt(5)]
          : null;

      final minSpend = [null, 99000, 149000, 199000, 299000][_rnd.nextInt(5)];

      final categoryId = _rnd.nextInt(10) + 1;

      final end = DateTime.now().add(
        Duration(days: _rnd.nextInt(25) - 5),
      ); // có mã đã/ sắp hết hạn
      final isHot = _rnd.nextDouble() < .25;
      final priority = 50 + _rnd.nextInt(50);

      _all.add(
        Coupon(
          id: (i + 1).toString(),
          code: 'CODE${1000 + i}',
          title: isPercent
              ? 'Giảm $discountValue% cho đơn hàng'
              : 'Giảm ${discountValue ~/ 1000}k cho đơn hàng',
          discountType: isPercent ? 'PERCENT' : 'FIXED',
          discountValue: discountValue,
          maxDiscount: maxDiscount,
          minSpend: minSpend,
          categoryId: categoryId,
          applicableTypes: (List.of(_types)..shuffle(_rnd)).take(3).toList(),
          expiredAt: end,
          priority: priority,
          tags: isHot ? const ['hot'] : const [],
          shopId: ['shopee', 'lazada', 'tiki', 'amazon'][_rnd.nextInt(4)],
          imageUrl: 'https://picsum.photos/seed/c$i/640/360',
          deeplink: null,
          trackingLink: 'https://example.com/track/$i',
        ),
      );
    }
  }

  @override
  Future<List<Coupon>> hot({int limit = 8}) async {
    final list =
        _all
            .where((c) => (c.tags.contains('hot')) || ((c.priority ?? 0) >= 80))
            .toList()
          ..sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
    return list.take(limit).toList();
  }

  @override
  Future<PageResult<Coupon>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
  }) async {
    var data = _all;

    if (categoryId != null) {
      data = data.where((c) => c.categoryId == categoryId).toList();
    }
    if (q != null && q.trim().isNotEmpty) {
      final qq = q.toLowerCase();
      data = data
          .where(
            (c) =>
                c.title.toLowerCase().contains(qq) ||
                c.code.toLowerCase().contains(qq),
          )
          .toList();
    }

    // Ưu tiên còn hạn trước, rồi theo priority
    data.sort((a, b) {
      final aExpired =
          (a.expiredAt != null && a.expiredAt!.isBefore(DateTime.now()))
          ? 1
          : 0;
      final bExpired =
          (b.expiredAt != null && b.expiredAt!.isBefore(DateTime.now()))
          ? 1
          : 0;
      if (aExpired != bExpired) return aExpired.compareTo(bExpired);
      return (b.priority ?? 0).compareTo(a.priority ?? 0);
    });

    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final slice = start >= data.length
        ? <Coupon>[]
        : data.sublist(start, end > data.length ? data.length : end);
    final hasMore = end < data.length;

    return PageResult(data: slice, hasMore: hasMore, nextPage: page + 1);
  }

  @override
  Future<Coupon?> getById(String id) async {
    try {
      return _all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
