import 'package:flutter/material.dart';
import '../../models/coupon.dart';
import '../../core/money.dart';
import '../screens/detail/voucher_detail_screen.dart';
import '../widgets/app_image.dart';

class VoucherCard extends StatelessWidget {
  final Coupon coupon;
  const VoucherCard({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    final isHot = coupon.tags.contains('hot') || (coupon.priority ?? 0) >= 80;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VoucherDetailScreen(couponId: coupon.id),
        ),
      ),
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
              child: AppImage(coupon.imageUrl, w: 80, h: 80, fit: BoxFit.cover),
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
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      _chip('Code: ${coupon.code}', primary: true, context: context),
                      if (coupon.maxDiscount != null)
                        _chip('Giảm ${money(coupon.maxDiscount!)}', context: context),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('HSD: ${_fmtDate(coupon.expiredAt)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            if (isHot)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HOT',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, {bool primary = false, required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: primary
            ? Theme.of(context).colorScheme.primary.withOpacity(.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: primary
              ? Theme.of(context).colorScheme.primary
              : Colors.black87,
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
