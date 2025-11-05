import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/product.dart';
import '../../models/coupon.dart';
import '../../core/money.dart';
import '../../core/pricing.dart';

import '../../data/repo/product_repo.dart';
import '../../data/repo/coupon_repo.dart';
import '../../data/impl/product_repo_mock.dart';
import '../../data/impl/coupon_repo_mock.dart';

import '../../widgets/app_image.dart';
import '../detail/voucher_detail_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepo _productRepo = ProductRepoMock();
  final CouponRepo _couponRepo = CouponRepoMock();

  Product? _p;
  PricingResult? _best; // chứa discount, finalPrice, coupon tốt nhất
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _productRepo.getById(widget.productId);
    PricingResult? best;
    if (p != null) {
      final cps = (await _couponRepo.list(pageSize: 999)).data;
      best = bestForProduct(p, cps);
    }
    if (!mounted) return;
    setState(() {
      _p = p;
      _best = best;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_p == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy sản phẩm')),
      );
    }
    final p = _p!;
    final int pct = _best?.discountPercentFor(p.basePrice) ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppImage(
              p.imageUrl,
              w: double.infinity,
              h: 260,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(p.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                money(_best?.finalPrice ?? p.basePrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              if (pct > 0)
                Text(
                  money(p.basePrice),
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.black45,
                  ),
                ),
              if (pct > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '$pct% OFF',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // ======= Chỉ 1 mã tốt nhất =======
          if (_best?.coupon != null) CouponInline(c: _best!.coupon!),

          const SizedBox(height: 20),
          const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Mô tả demo sản phẩm. Ảnh, tên, giá và 1 mã áp dụng tốt nhất hiển thị để thử luồng.',
          ),
        ],
      ),
    );
  }
}

// --- Widget: Coupon inline (1 mã duy nhất) ---
class CouponInline extends StatelessWidget {
  final Coupon c;
  const CouponInline({super.key, required this.c});

  Future<void> _openLink(BuildContext context) async {
    final link = c.deeplink ?? c.trackingLink;
    if (link == null || link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã này chưa có liên kết dùng ngay.')),
      );
      return;
    }
    if (await canLaunchUrlString(link)) {
      await launchUrlString(link, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không mở được liên kết: $link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHot = (c.tags.contains('hot')) || ((c.priority ?? 0) >= 80);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề + HOT badge
          Row(
            children: [
              Expanded(
                child: Text(
                  c.title,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (isHot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'HOT',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Mã + giá trị
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _chip('Code: ${c.code}', primary: true),
              if (c.maxDiscount != null)
                _chip('Giảm ${money(c.maxDiscount!)}'),
            ],
          ),
          const SizedBox(height: 6),
          Text('HSD: ${_fmtDate(c.expiredAt)}', style: textTheme.bodySmall),

          const Divider(height: 20),

          // Hàng nút
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: c.code));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Đã copy mã')));
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy mã'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openLink(context),
                  icon: const Icon(Icons.launch, size: 18),
                  label: const Text('Dùng mã'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Link xem chi tiết
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VoucherDetailScreen(couponId: c.id),
                  ),
                );
              },
              child: const Text('Xem chi tiết mã'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, {bool primary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary ? Colors.blue.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: primary ? Colors.blue.shade700 : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Không xác định';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}