import '../../models/category.dart';
import '../repo/category_repo.dart'; // 👈 import interface (đường dẫn đúng)

class CategoryRepoMock implements CategoryRepo {
  final List<Category> _cats =
      List.generate(10, (i) => Category(id: i + 1, name: 'Danh mục ${i + 1}'));

  @override
  Future<List<Category>> list() async => _cats;
}
