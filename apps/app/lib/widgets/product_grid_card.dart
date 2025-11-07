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

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductGridCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final old = product.originalPrice ?? product.basePrice;
    final pct = old > 0 ? (((old - product.basePrice) / old) * 100).round() : 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                ? Image.network(product.imageUrl!, height: 140, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 140, color: const Color(0xFFEDEDED)))
                : Container(height: 140, color: const Color(0xFFEDEDED)),
          ),
          const SizedBox(height: 8),
          Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [
            Text(_money(product.basePrice), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            if (old > product.basePrice)
              Text(_money(old), style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black54)),
          ]),
          const SizedBox(height: 2),
          if (pct > 0) Text('$pct% OFF', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12)),
        ]),
      ),
    );
  }
}
