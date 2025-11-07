import '../repo/coupon_repo.dart';
import '../../models/coupon.dart';
import 'dart:math';

class CouponRepoMock implements CouponRepo {
  static final List<Coupon> _data = List.generate(60, (i) {
    final isPercent = i % 2 == 0;
    final percent = 10 + (i % 5) * 5; // 10/15/20/25/30
    final fixed = 20000 + (i % 5) * 30000; // 20k..140k
    return Coupon(
      id: 'c${i + 1}',
      title: isPercent ? 'Giảm $percent% toàn sàn' : 'Giảm ${fixed ~/ 1000}k',
      code: 'CODE${1000 + i}',
      discountType: isPercent ? 'PERCENT' : 'FIXED',
      discountValue: isPercent ? percent.toDouble() : fixed.toDouble(),
      minSpend: (i % 3 == 0) ? 150000 : null,
      maxDiscount: isPercent ? 100000 : null,
      expiredAt: DateTime.now().add(Duration(days: 7 + i)),
      categoryId: (i % 6) + 1,
      shopId: ['shopee', 'lazada', 'tiki'][i % 3],
      imageUrl: 'https://picsum.photos/seed/c${i + 1}/600/400',
      tags: i % 4 == 0 ? ['hot'] : [],
      priority: i % 4 == 0 ? 90 : 50,
      trackingLink: 'https://example.com/track/${i + 1}',
      deeplink: 'https://example.com/deeplink/${i + 1}',
      isActive: true,
    );
  });

  Future<List<Coupon>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
    String? sort,
    String? shopId,
  }) async {
    var list = _data.where((e) => e.isActive).toList();
    if (categoryId != null)
      list = list.where((e) => e.categoryId == categoryId).toList();
    if (shopId != null) list = list.where((e) => e.shopId == shopId).toList();
    if (q != null && q.isNotEmpty) {
      list = list
          .where(
            (e) =>
                e.title.toLowerCase().contains(q.toLowerCase()) ||
                e.code.toLowerCase().contains(q.toLowerCase()),
          )
          .toList();
    }
    switch (sort) {
      case 'priorityDesc':
      case 'hot':
        list.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
        break;
      case 'endAtAsc':
        list.sort(
          (a, b) => (a.expiredAt ?? DateTime(2100)).compareTo(
            b.expiredAt ?? DateTime(2100),
          ),
        );
        break;
      default:
        list.sort((a, b) => a.id.compareTo(b.id));
    }
    final start = (page - 1) * pageSize;
    final end = min(start + pageSize, list.length);
    return start >= list.length ? [] : list.sublist(start, end);
  }

  Future<List<Coupon>> hot({int limit = 10}) async {
    final list = _data
        .where(
          (c) => (c.tags?.contains('hot') ?? false) || (c.priority ?? 0) >= 80,
        )
        .toList();
    list.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
    return list.take(limit).toList();
  }

  Future<Coupon?> getById(String id) async {
    try {
      return _data.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
