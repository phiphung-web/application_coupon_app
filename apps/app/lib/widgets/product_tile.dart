import 'package:flutter/material.dart';
import '../models/product.dart';

String _money(num v) {
  final s = v.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - 1 - i;
    buf.write(s[idx]);
    if ((i + 1) % 3 == 0 && idx != 0) buf.write('.');
  }
  return buf.toString().split('').reversed.join() + 'đ';
}

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductTile({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final old = product.originalPrice ?? product.basePrice;

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                ? Image.network(product.imageUrl!, width: 90, height: 90, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 90, height: 90, color: const Color(0xFFEDEDED)))
                : Container(width: 90, height: 90, color: const Color(0xFFEDEDED)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Text(_money(product.basePrice), style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                if (old > product.basePrice)
                  Text(_money(old), style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black54)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
