import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/coupon.dart';
import '../core/money.dart';
import 'app_image.dart';

class CouponListItem extends StatelessWidget {
  final Coupon c;
  final VoidCallback? onTap;

  const CouponListItem({super.key, required this.c, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isHot = c.tags.contains('hot') || (c.priority ?? 0) >= 80;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppImage(c.imageUrl, w: 72, h: 72, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(child: _CenterPart(c: c)),
            if (isHot) const SizedBox(width: 8),
            if (isHot) _pill(context, 'HOT', dark: true),
          ],
        ),
      ),
    );
  }
}

class _CenterPart extends StatelessWidget {
  final Coupon c;
  const _CenterPart({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề
        Text(
          c.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),

        // Chip thông tin
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _pill(
              context,
              'Code: ${c.code}',
              primary: true,
              onTap: () {
                Clipboard.setData(ClipboardData(text: c.code));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã copy mã')));
              },
            ),
            if (c.minSpend != null) _pill(context, 'Min ${money(c.minSpend!)}'),
            if (c.maxDiscount != null)
              _pill(context, 'Max ${money(c.maxDiscount!)}'),
            _pill(context, _discountLabel(c)),
          ],
        ),

        const SizedBox(height: 6),
        Text(
          'HSD: ${_fmtDate(c.expiredAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ===== helpers =====
Widget _pill(
  BuildContext ctx,
  String t, {
  bool primary = false,
  bool dark = false,
  VoidCallback? onTap,
}) {
  final bg = dark
      ? Colors.black87
      : primary
      ? Theme.of(ctx).colorScheme.primary.withOpacity(.1)
      : Theme.of(ctx).colorScheme.surfaceVariant.withOpacity(.8);
  final fg = dark
      ? Colors.white
      : primary
      ? Theme.of(ctx).colorScheme.primary
      : Theme.of(ctx).colorScheme.onSurfaceVariant;
  final child = Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      t,
      style: TextStyle(
        fontSize: 12,
        color: fg,
        fontWeight: primary ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
  if (onTap == null) return child;
  return GestureDetector(onTap: onTap, child: child);
}

String _discountLabel(Coupon c) {
  final t = (c.discountType).toUpperCase();
  return (t == 'PERCENT')
      ? 'Giảm ${c.discountValue}%'
      : 'Giảm ${money(c.discountValue)}';
}

String _fmtDate(DateTime? d) {
  if (d == null) return '-';
  String two(int x) => x < 10 ? '0$x' : '$x';
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}
