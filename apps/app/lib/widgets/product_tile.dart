import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../core/money.dart';
import '../core/pricing.dart';
import '../models/product.dart';
import '../models/coupon.dart';
import 'app_image.dart';
import 'app_button.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final List<Coupon> coupons;
  const ProductTile({super.key, required this.product, required this.coupons});

  @override
  Widget build(BuildContext context) {
    final pr = bestForProduct(product, coupons);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppImage(product.imageUrl, w: 92, h: 92),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      money(pr.finalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      money(product.basePrice),
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                if (pr.coupon != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('-${money(pr.discount)}'),
                        ),
                        Text(
                          'Code: ${pr.coupon!.code}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        AppButton(
                          label: 'Copy',
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: pr.coupon!.code),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã copy mã')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
