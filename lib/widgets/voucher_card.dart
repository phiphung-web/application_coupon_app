import 'package:flutter/material.dart';

class VoucherCard extends StatelessWidget {
  final String title;
  final String code;
  final String? imageUrl;
  final String? badge; // HOT | FLASH | null
  final String shop;
  final DateTime endAt;
  final VoidCallback? onCopy;
  final VoidCallback? onUse;
  final VoidCallback? onFav;

  const VoucherCard({
    super.key,
    required this.title,
    required this.code,
    required this.shop,
    required this.endAt,
    this.imageUrl,
    this.badge,
    this.onCopy,
    this.onUse,
    this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    final remain = endAt.difference(DateTime.now().toUtc());
    final d = remain.inDays;
    final h = remain.inHours % 24;
    return Card(
      child: InkWell(
        onTap: onUse,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: imageUrl != null
                  ? Image.network(imageUrl!, width: 110, height: 110, fit: BoxFit.cover)
                  : Container(width: 110, height: 110, color: const Color(0xFFEAEAEA)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(badge!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    const SizedBox(height: 4),
                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Shop: $shop · HSD: ${d}d ${h}h',
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(code, style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
                        ),
                        const Spacer(),
                        IconButton(onPressed: onFav, icon: const Icon(Icons.favorite_border)),
                        const SizedBox(width: 4),
                        FilledButton.tonal(onPressed: onCopy, child: const Text('Copy')),
                        const SizedBox(width: 8),
                        FilledButton(onPressed: onUse, child: const Text('Dùng ngay')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
