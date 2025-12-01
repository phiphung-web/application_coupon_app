import 'package:flutter/material.dart';
import '../core/money.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({super.key, required this.product, this.onTap});

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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  ? Image.network(
                      product.imageUrl!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 110,
                        height: 110,
                        color: const Color(0xFFEDEDED),
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 110,
                      color: const Color(0xFFEDEDED),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 4),
                  if (pct > 0)
                    Text(
                      '$pct% OFF',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
