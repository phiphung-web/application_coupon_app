import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/product.dart';
import '../../models/coupon.dart';
import '../../core/pricing.dart';
import '../../data/impl/coupon_repo_mock.dart';
import '../../data/impl/product_repo_mock.dart';

String _money(num v) {
  final s = v.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - 1 - i;
    buf.write(s[idx]);
    if ((i + 1) % 3 == 0 && idx != 0) buf.write('.');
  }
  return buf.toString().split('').reversed.join() + 'đ';
}

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _pRepo = ProductRepoMock();
  final _cRepo = CouponRepoMock();

  Product? _p;
  PricingResult? _best;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _pRepo.getById(widget.productId);
    PricingResult? pr;
    if (p != null) {
      final coupons = await _cRepo.list(pageSize: 999);
      pr = bestForProduct(p, coupons);
    }
    if (!mounted) return;
    setState(() {
      _p = p;
      _best = pr;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_p == null) return const Center(child: Text('Không tìm thấy sản phẩm'));

    final p = _p!;
    final best = _best;
    final old = p.originalPrice ?? p.basePrice;
    final finalPrice = best?.finalPrice ?? p.basePrice;
    final pct = old > 0 ? (((old - finalPrice) / old) * 100).round() : 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            p.imageUrl ?? '',
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(height: 220, color: const Color(0xFFEDEDED)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          p.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              _money(finalPrice),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            if (old > finalPrice)
              Text(
                _money(old),
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.black45,
                ),
              ),
            if (old > finalPrice) ...[
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
        if (best?.coupon != null) _CouponInline(c: best!.coupon!),
        const SizedBox(height: 16),
        const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(p.description ?? 'Mô tả demo sản phẩm.'),
      ],
    );
  }
}

class _CouponInline extends StatelessWidget {
  final Coupon c;
  const _CouponInline({required this.c});

  Future<void> _openLink(BuildContext context) async {
    final link = c.deeplink ?? c.trackingLink;
    if (link == null || link.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa có liên kết dùng mã')));
      return;
    }
    if (await canLaunchUrlString(link)) {
      await launchUrlString(link, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không mở được: $link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHot = (c.tags?.contains('hot') ?? false) || (c.priority ?? 0) >= 80;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  c.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (isHot)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'HOT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip(
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
              if (c.minSpend != null)
                _chip(context, 'Min ${_money(c.minSpend!)}'),
              if (c.maxDiscount != null)
                _chip(context, 'Max ${_money(c.maxDiscount!)}'),
              _chip(
                context,
                c.discountType.toUpperCase() == 'PERCENT'
                    ? 'Giảm ${c.discountValue.toInt()}%'
                    : 'Giảm ${_money(c.discountValue)}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'HSD: ${_fmtDate(c.expiredAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: c.code));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Đã copy mã')));
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
          Center(
            child: TextButton(
              onPressed: () {
                // Nếu bạn có AppRoutes.coupon thì dùng pushNamed
                // Navigator.of(context).pushNamed(AppRoutes.coupon, arguments: c.id);
                Navigator.of(context).push(
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

  Widget _chip(
    BuildContext ctx,
    String text, {
    bool primary = false,
    VoidCallback? onTap,
  }) {
    final bg = primary
        ? Theme.of(ctx).colorScheme.primary.withOpacity(.1)
        : Colors.grey.shade200;
    final fg = primary ? Theme.of(ctx).colorScheme.primary : Colors.black87;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
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

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    String two(int x) => x < 10 ? '0$x' : '$x';
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}

class VoucherDetailScreen extends StatelessWidget {
  final String couponId;
  const VoucherDetailScreen({super.key, required this.couponId});
  @override
  Widget build(BuildContext context) {
    // Placeholder (file chi tiết voucher thật ở phần dưới)
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết mã')),
      body: Center(child: Text('Mã: $couponId')),
    );
  }
}
