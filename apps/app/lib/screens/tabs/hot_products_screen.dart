import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../data/repo/product_repo.dart';
import '../../data/impl/product_repo_mock.dart';
import '../../widgets/product_card.dart';
import '../detail/product_detail_screen.dart';

class HotProductsScreen extends StatefulWidget {
  const HotProductsScreen({super.key});
  @override
  State<HotProductsScreen> createState() => _HotProductsScreenState();
}

class _HotProductsScreenState extends State<HotProductsScreen> {
  final ProductRepo _repo = ProductRepoMock();
  List<Product> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.hot(limit: 120);
    list.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm hot')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _items.length,
                itemBuilder: (_, i) => ProductCard(
                  product: _items[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(productId: _items[i].id),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
