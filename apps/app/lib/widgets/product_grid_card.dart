import 'package:flutter/material.dart';
import '../core/money.dart';
import '../models/product.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductGridCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final current = product.priceEffective;
    final original = product.priceOriginal;
    final pct = product.discountPercent;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  ? Image.network(
                      product.imageUrl!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(height: 140, color: const Color(0xFFEDEDED)),
                    )
                  : Container(height: 140, color: const Color(0xFFEDEDED)),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  money(current),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 6),
                if (original > current)
                  Text(
                    money(original),
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            if (pct > 0)
              Text(
                '$pct% OFF',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
