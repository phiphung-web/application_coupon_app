import 'package:flutter/material.dart';
import '../../data/impl/product_repo_mock.dart';
import '../../models/product.dart';
import '../detail/product_detail_screen.dart';
import '../../widgets/product_grid_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _repo = ProductRepoMock();
  final _scroll = ScrollController();
  final _items = <Product>[];
  int _page = 1;
  bool _loading = false;
  bool _end = false;

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200)
        _loadMore();
    });
  }

  Future<void> _loadFirst() async {
    setState(() => _loading = true);
    final data = await _repo.list(page: 1, pageSize: 20);
    setState(() {
      _items
        ..clear()
        ..addAll(data);
      _page = 1;
      _end = data.length < 20;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loading || _end) return;
    setState(() => _loading = true);
    final data = await _repo.list(page: _page + 1, pageSize: 20);
    setState(() {
      _items.addAll(data);
      _page += 1;
      if (data.length < 20) _end = true;
      _loading = false;
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
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
