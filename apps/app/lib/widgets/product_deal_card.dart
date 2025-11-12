import 'package:flutter/material.dart';
import 'app_image.dart';

class ProductDealCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final int priceOriginal;
  final int? priceAfter; // null náº¿u khÃ´ng cÃ³ mÃ£ phÃ¹ há»£p
  final String? couponCode;
  final VoidCallback? onTap;

  const ProductDealCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.priceOriginal,
    this.priceAfter,
    this.couponCode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDeal = priceAfter != null && priceAfter! < priceOriginal;
    final saved = hasDeal ? (priceOriginal - priceAfter!) : 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0,2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AppImage(imageUrl, h: 120, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (hasDeal) ...[
                        Text(_fmt(priceAfter!),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(_fmt(priceOriginal),
                            style: const TextStyle(
                              color: Colors.black45,
                              decoration: TextDecoration.lineThrough,
                            )),
                      ] else
                        Text(_fmt(priceOriginal),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const Spacer(),
                      if (hasDeal)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6FFEF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('-${_fmt(saved)}',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  if (couponCode != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Ãp dá»¥ng mÃ£ $couponCode'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final reversedIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reversedIndex > 1 && reversedIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    final formatted = buffer.toString();
    return '$formatted₫';
  }
}