import 'package:flutter/material.dart';

import '../../data/impl/product_repo_remote.dart';
import '../../data/repo/product_repo.dart';
import '../../models/product.dart';
import '../../widgets/product_grid_card.dart';
import '../detail/product_detail_screen.dart';

class HotProductsScreen extends StatelessWidget {
  const HotProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductRepo repo = ProductRepoRemote();
    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm nổi bật')),
      body: FutureBuilder<List<Product>>(
        future: repo.hot(limit: 40),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .62,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => ProductGridCard(
                product: items[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: items[i].id),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
