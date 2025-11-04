import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/impl/coupon_repo_mock.dart';
import '../../data/impl/favorites_local.dart';
import '../../widgets/app_image.dart';

class VoucherDetailScreen extends StatefulWidget {
  final String couponId;
  const VoucherDetailScreen({super.key, required this.couponId});

  @override
  State<VoucherDetailScreen> createState() => _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends State<VoucherDetailScreen> {
  final repo = CouponRepoMock();
  final fav = FavoritesLocal();
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _initFav();
  }

  Future<void> _initFav() async {
    final has = await fav.has(widget.couponId);
    if (mounted) setState(() => _isFav = has);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chi tiết mã'),
        actions: [
          IconButton(
            icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              await fav.toggle(widget.couponId);
              await _initFav();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(_isFav
                      ? 'Đã thêm yêu thích'
                      : 'Đã bỏ yêu thích'))); // trạng thái sau toggle
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: repo.getById(widget.couponId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final c = snap.data!;
          final remain = c.endAt.difference(DateTime.now().toUtc());
          final d = remain.inDays;
          final h = remain.inHours % 24;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppImage(c.imageUrl, h: 180),
              ),
              const SizedBox(height: 12),
              Text(c.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Shop: ${c.shopId} · HSD: ${d}d ${h}h',
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(c.code,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonal(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: c.code));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã copy mã')));
                    },
                    child: const Text('Copy mã'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      final link = c.trackingLink ?? c.deeplink;
                      if (link == null || link.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Không có liên kết dùng mã')),
                        );
                        return;
                      }
                      final uri = Uri.parse(link);
                      if (!await canLaunchUrl(uri)) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không mở được liên kết')),
                        );
                        return;
                      }
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: const Text('Dùng ngay'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (c.minSpend != null) Text('Đơn tối thiểu: ${c.minSpend}'),
              if (c.maxDiscount != null) Text('Giảm tối đa: ${c.maxDiscount}'),
              const SizedBox(height: 8),
              const Text('Điều kiện áp dụng',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(c.terms ?? 'Không có'),
            ],
          );
        },
      ),
    );
  }
}
