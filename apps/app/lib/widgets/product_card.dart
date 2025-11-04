import '../core/discount.dart';
import '../models/product.dart';
import '../models/coupon.dart';
import 'package:flutter/material.dart';
import 'app_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final List<Coupon> coupons;
  const ProductCard({super.key, required this.product, required this.coupons});

  @override
  Widget build(BuildContext context) {
    final r = bestDiscount(product, coupons);
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(url: product.image, height: 110, radius: 12),
          const SizedBox(height: 8),
          Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                _money(r.finalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _money(product.price),
                style: const TextStyle(decoration: TextDecoration.lineThrough),
              ),
            ],
          ),
          if (r.coupon != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Tiết kiệm ${_money(r.discount)} với ${r.coupon!.code}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  String _money(int v) =>
      '${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
}
