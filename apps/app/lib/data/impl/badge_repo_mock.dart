import '../../models/badge.dart';
import '../repo/badge_repo.dart';

class BadgeRepoMock implements BadgeRepo {
  static const _badges = <Badge>[
    Badge(id: 1, key: 'HOT', label: 'Hot', priority: 100),
    Badge(id: 2, key: 'FLASH', label: 'Flash Sale', priority: 80),
    Badge(id: 3, key: 'NEW', label: 'New', priority: 60),
    Badge(id: 4, key: 'TREND', label: 'Trend', priority: 50),
  ];

  @override
  Future<List<Badge>> list({bool activeOnly = true}) async {
    return _badges;
  }
}
