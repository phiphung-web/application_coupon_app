import '../../models/category.dart';
import '../repo/category_repo.dart';

class CategoryRepoMock implements CategoryRepo {
  final List<Category> _cats =
      List.generate(10, (i) => Category(id: i + 1, name: 'Danh mục ${i + 1}'));

  @override
  Future<List<Category>> list() async => _cats;

  @override
  Future<List<Category>> highlights({int limit = 6}) async =>
      _cats.take(limit).toList();
}

