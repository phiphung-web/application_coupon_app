import 'package:flutter/material.dart';
import '../core/money.dart';
import '../models/coupon.dart';
import 'app_image.dart';
import 'badge.dart';

class VoucherCard extends StatelessWidget {
  final Coupon c;
  final VoidCallback? onTap;
  const VoucherCard({super.key, required this.c, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AppImage(
                  c.imageUrl,
                  w: double.infinity,
                  h: 100,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (c.isHot || c.priority >= 80 || c.tags.contains('hot'))
                        const SizedBox(width: 8),
                      if (c.isHot || c.priority >= 80 || c.tags.contains('hot'))
                        const Badge('HOT'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text(c.code)),
                      if (c.minOrder != null)
                        Chip(label: Text('Min ${money(c.minOrder!)}')),
                      if (c.maxDiscount != null)
                        Chip(label: Text('Max ${money(c.maxDiscount!)}')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('HSD: ${c.endAt}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
