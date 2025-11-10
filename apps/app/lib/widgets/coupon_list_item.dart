import 'package:flutter/material.dart';
import '../core/money.dart';
import '../models/coupon.dart';

class CouponListItem extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback? onTap;
  const CouponListItem({super.key, required this.coupon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isHot = coupon.badges.any(
          (b) => b.key.toUpperCase() == 'HOT',
        ) ||
        (coupon.priority ?? 0) >= 80;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
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
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (coupon.imageUrl != null && coupon.imageUrl!.isNotEmpty)
                  ? Image.network(
                      coupon.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFFEDEDED),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFEDEDED),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      _chip(context, 'Code: ${coupon.code}', primary: true),
                      if (coupon.maxDiscount != null)
                        _chip(
                          context,
                          'Giảm ${money(coupon.maxDiscount!)}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'HSD: ${_fmtDate(coupon.endAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (isHot)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HOT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext ctx, String text, {bool primary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: primary
            ? Theme.of(ctx).colorScheme.primary.withOpacity(.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: primary ? Theme.of(ctx).colorScheme.primary : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
