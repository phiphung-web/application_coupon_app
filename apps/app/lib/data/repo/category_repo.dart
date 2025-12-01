import '../../models/category.dart';

abstract class CategoryRepo {
  Future<List<Category>> list();
  Future<List<Category>> highlights({int limit});
}
