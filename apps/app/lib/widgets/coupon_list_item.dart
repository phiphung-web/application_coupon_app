import 'package:flutter/material.dart';

import '../core/money.dart';
import '../models/coupon.dart';

class CouponListItem extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback? onTap;
  const CouponListItem({super.key, required this.coupon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryBadge = coupon.badges.isNotEmpty ? coupon.badges.first : null;
    final badgeColor = _colorFromHex(primaryBadge?.color ?? primaryBadge?.bgColor);
    final isHot = coupon.badges.any((b) => b.key.toUpperCase() == 'HOT') || (coupon.priority ?? 0) >= 80;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (coupon.imageUrl != null && coupon.imageUrl!.isNotEmpty)
                  ? Image.network(
                      coupon.imageUrl!,
                      width: 82,
                      height: 82,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(width: 82, height: 82, color: Colors.grey.shade200),
                    )
                  : Container(
                      width: 82,
                      height: 82,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.confirmation_number_outlined),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (primaryBadge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor?.withOpacity(.1) ?? Colors.orange.withOpacity(.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        primaryBadge.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: badgeColor ?? Colors.orange,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _chip(context, 'Code: ${coupon.code}', primary: true),
                      _chip(
                        context,
                        coupon.isPercent
                            ? 'Gi?m ${coupon.discountValue}%'
                            : 'Gi?m ${money(coupon.discountValue)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ngu?n: ${coupon.sourceName ?? (coupon.sourceId ?? 'Toàn sàn')}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    'HSD: ${_fmtDate(coupon.endAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(isHot ? Icons.whatshot : Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext ctx, String text, {bool primary = false}) {
    final color = primary ? Theme.of(ctx).colorScheme.primary : Colors.black87;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: primary ? color.withOpacity(.1) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(0xff000000 | value);
  }
}
