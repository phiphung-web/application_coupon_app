import '../../models/badge.dart';

abstract class BadgeRepo {
  Future<List<Badge>> list({bool activeOnly = true});
}
