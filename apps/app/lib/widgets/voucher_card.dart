import 'package:flutter/material.dart';
import 'app_image.dart';
import 'countdown.dart';

class VoucherCard extends StatelessWidget {
  final String title;
  final String code;
  final String shop;
  final DateTime endAt;
  final String? imageUrl;
  final String? badge;
  final VoidCallback? onTap;
  final VoidCallback? onFav;

  const VoucherCard({
    super.key,
    required this.title,
    required this.code,
    required this.shop,
    required this.endAt,
    this.imageUrl,
    this.badge,
    this.onTap,
    this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: AppImage(imageUrl, w: 110, h: 110),
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
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text('Mã: $code · Shop: $shop', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Countdown(endAtUtc: endAt),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}
