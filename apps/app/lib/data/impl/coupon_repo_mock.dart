import 'dart:math';

import '../../core/result.dart';
import '../../models/badge.dart';
import '../../models/coupon.dart';
import '../../models/coupon_category.dart';
import '../repo/coupon_repo.dart';

class CouponRepoMock implements CouponRepo {
  static final _categories = List<CouponCategory>.generate(
    6,
    (i) => CouponCategory(
      id: i + 1,
      name: 'Coupon cat ${i + 1}',
      description: 'Danh mục coupon demo #${i + 1}',
    ),
  );

  static final _hotBadge =
      const Badge(id: 10, key: 'HOT', label: 'Hot', priority: 90);

  static final List<Coupon> _data = List.generate(70, (index) {
    final isPercent = index % 2 == 0;
    final percent = 10 + (index % 5) * 5;
    final fixed = 20000 + (index % 6) * 15000;
    final cat = _categories[index % _categories.length];
    final badgeList = <Badge>[];
    if (index % 4 == 0) badgeList.add(_hotBadge);

    final start = DateTime.now().subtract(Duration(days: index % 4));
    final end = DateTime.now().add(Duration(days: 5 + index));

    return Coupon(
      id: index + 1,
      title: isPercent
          ? 'Giảm $percent% toàn sàn'
          : 'Giảm ${fixed ~/ 1000}k đơn hàng',
      code: 'CODE${1000 + index}',
      discountType: isPercent ? 'PERCENT' : 'FIXED_AMOUNT',
      discountValue: isPercent ? percent : fixed,
      minSpend: index % 3 == 0 ? 150000 : null,
      maxDiscount: isPercent ? 120000 : null,
      startDate: start,
      endDate: end,
      sourceId: ['1', '2', '3'][index % 3],
      sourceName: ['Shopee', 'Lazada', 'Tiki'][index % 3],
      imageUrl: 'https://picsum.photos/seed/c${index + 1}/600/400',
      categories: [cat],
      badges: badgeList,
      dealUrl: 'https://example.com/deal/${index + 1}',
      priority: badgeList.isNotEmpty ? 90 : 50,
      trackingLink: 'https://example.com/track/${index + 1}',
      deeplink: 'https://example.com/deeplink/${index + 1}',
      isActive: true,
    );
  });

  @override
  Future<PageResult<Coupon>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
    String? sort,
    String? shopId,
    String? badgeKey,
    String? discountType,
    DateTime? expiresFrom,
    DateTime? expiresTo,
  }) async {
    var list = _data.where((c) => c.isActive).toList();
    if (categoryId != null) {
      list = list
          .where(
            (c) => c.categories.any((cat) => cat.id == categoryId),
          )
          .toList();
    }
    if (shopId != null && shopId.isNotEmpty) {
      list = list.where((c) => c.sourceId == shopId).toList();
    }
    if (badgeKey != null && badgeKey.isNotEmpty) {
      final key = badgeKey.toUpperCase();
      list = list
          .where(
            (c) => c.badges.any((b) => b.key.toUpperCase() == key),
          )
          .toList();
    }
    if (q != null && q.isNotEmpty) {
      final query = q.toLowerCase();
      list = list
          .where(
            (c) =>
                c.title.toLowerCase().contains(query) ||
                c.code.toLowerCase().contains(query),
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
          (a, b) => (a.endAt ?? DateTime(2100)).compareTo(b.endAt ?? DateTime(2100)),
        );
        break;
      default:
        list.sort((a, b) => a.id.compareTo(b.id));
    }

    final startIdx = (page - 1) * pageSize;
    final endIdx = min(startIdx + pageSize, list.length);
    final meta = {'page': page, 'limit': pageSize, 'total': list.length};
    final slice =
        (startIdx >= list.length) ? <Coupon>[] : list.sublist(startIdx, endIdx);
    final hasMore = endIdx < list.length;

    return PageResult<Coupon>(
      data: slice,
      hasMore: hasMore,
      nextPage: hasMore ? page + 1 : page,
      meta: meta,
    );
  }

  @override
  Future<List<Coupon>> hot({int limit = 10}) async {
    final list = _data
        .where(
          (c) =>
              c.badges.any((b) => b.key.toUpperCase() == 'HOT') ||
              (c.priority ?? 0) >= 80,
        )
        .toList();
    list.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
    return list.take(limit).toList();
  }

  @override
  Future<Coupon?> getById(int id) async {
    try {
      return _data.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
