import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart'; // nhớ thêm vào pubspec.yaml
import '../../data/impl/coupon_repo_mock.dart'; // CouponItem + CouponRepoMock
import '../../data/repo/coupon_repo.dart';

class VoucherDetailScreen extends StatefulWidget {
  final int couponId;
  const VoucherDetailScreen({super.key, required this.couponId});
  @override
  State<VoucherDetailScreen> createState() => _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends State<VoucherDetailScreen> {
  final CouponRepo _repo = CouponRepoMock();
  late final Future<Coupon?> _future = _repo.getById(widget.couponId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết mã')),
      body: FutureBuilder<Coupon?>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final c = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (c.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImage(c.imageUrl, w: double.infinity, h: 180),
                ),
              const SizedBox(height: 12),
              Text(c.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Shop: ${c.shopId ?? "-"}  •  HSD: ${c.endAt}'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('Code: ${c.code}')),
                  if (c.minOrder != null)
                    Chip(label: Text('Min ${money(c.minOrder!)}')),
                  if (c.maxDiscount != null)
                    Chip(label: Text('Max ${money(c.maxDiscount!)}')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  AppButton(
                    label: 'Copy mã',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: c.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã copy mã')),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  if (c.trackingLink != null || c.deeplink != null)
                    AppButton(
                      label: 'Dùng ngay',
                      color: Colors.green,
                      onPressed: () {
                        // TODO: mở link ngoài/deeplink
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Điều kiện áp dụng',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              ...c.terms.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $t'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
