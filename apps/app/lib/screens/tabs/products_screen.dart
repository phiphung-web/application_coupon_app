import 'package:flutter/material.dart';
import '../../core/result.dart';
import '../../data/impl/product_repo_remote.dart';
import '../../data/repo/product_repo.dart';
import '../../models/product.dart';
import '../detail/product_detail_screen.dart';
import '../../widgets/product_grid_card.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/retry_view.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductRepo _repo = ProductRepoRemote();
  final _scroll = ScrollController();
  final _items = <Product>[];
  int _page = 1;
  bool _loading = false;
  bool _end = false;
  bool _fallbackNotified = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final PageResult<Product> data = await _repo.list(page: 1, pageSize: 20);
      setState(() {
        _items
          ..clear()
          ..addAll(data.data);
        _page = data.nextPage;
        _end = !data.hasMore;
        _loading = false;
      });
      _maybeNotifyFallback(data.fromFallback);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Không tải được danh sách sản phẩm.';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _end) return;
    setState(() => _loading = true);
    final PageResult<Product> data = await _repo.list(page: _page, pageSize: 20);
    setState(() {
      _items.addAll(data.data);
      _page = data.nextPage;
      _end = !data.hasMore;
      _loading = false;
    });
    _maybeNotifyFallback(data.fromFallback);
  }

  void _maybeNotifyFallback(bool fromFallback) {
    if (!fromFallback || _fallbackNotified) return;
    _fallbackNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không kết nối được server, đang tạm hiển thị dữ liệu demo.'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFirst,
      child: ListView(
        controller: _scroll,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tất cả sản phẩm',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          if (_items.isEmpty && _loading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: buildGridSkeleton(
                  count: 4,
                  height: 200,
                ),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: RetryView(
                message: _error!,
                onRetry: _loadFirst,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .62,
              ),
              itemCount: _items.length,
              itemBuilder: (_, i) => ProductGridCard(
                product: _items[i],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(productId: _items[i].id),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_end)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('Hết dữ liệu')),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
