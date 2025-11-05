import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../core/money.dart';
import '../screens/detail/product_detail_screen.dart';
import '../widgets/app_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: product.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppImage(product.imageUrl, h: 120, w: double.infinity),
            ),
            const SizedBox(height: 8),

            // Tên
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),

            // Giá
            Row(
              children: [
                Text(
                  money(product.basePrice),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                if (product.oldPrice != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    money(product.oldPrice!),
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),

            // Tag nhỏ
            Row(
              children: [
                if (product.discountPercent != null)
                  Text(
                    '${product.discountPercent}% OFF',
                    style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                const SizedBox(width: 6),
                const Text(
                  'PROMO CODE',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
