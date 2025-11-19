import '../../core/result.dart';
import '../../models/product.dart';

abstract class ProductRepo {
  Future<List<Product>> hot({int limit = 8});
  Future<PageResult<Product>> list({
    int page = 1,
    int pageSize = 20,
    int? categoryId,
    String? q,
    String? sort,
    String? shopId,
    String? itemType,
    int? minPrice,
    int? maxPrice,
    bool? hasCoupon,
  });
  Future<Product?> getById(int id);
}
