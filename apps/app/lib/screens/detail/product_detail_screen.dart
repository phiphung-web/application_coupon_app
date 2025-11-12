import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/money.dart';
import '../../core/pricing.dart';
import '../../data/impl/coupon_repo_remote.dart';
import '../../data/impl/product_repo_remote.dart';
import '../../data/repo/coupon_repo.dart';
import '../../data/repo/product_repo.dart';
import '../../models/coupon.dart';
import '../../models/product.dart';
import 'voucher_detail_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepo _pRepo = ProductRepoRemote();
  final CouponRepo _cRepo = CouponRepoRemote();

  Product? _product;
  PricingResult? _best;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _pRepo.getById(widget.productId);
    PricingResult? best;
    if (p != null) {
      if (p.bestDeal != null) {
        best = PricingResult(
          finalPrice: p.bestDeal!.after,
          discountAmount: p.bestDeal!.saved,
          coupon: p.bestDeal!.coupon,
        );
      } else {
        final coupons = (await _cRepo.list(pageSize: 200)).data;
        best = bestForProduct(p, coupons);
      }
    }

    if (!mounted) return;
    setState(() {
      _product = p;
      _best = best;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_product == null) {
      return const Center(child: Text('KhÃ´ng tÃ¬m tháº¥y sáº£n pháº©m'));
    }

    final p = _product!;
    final appliedPrice = _best?.finalPrice ?? p.priceEffective;
    final old = p.priceOriginal;
    final pct = old > 0 ? ((old - appliedPrice) * 100 ~/ old) : 0;
    final Coupon? coupon = _best?.coupon;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
              ? Image.network(
                  p.imageUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(height: 220, color: const Color(0xFFEDEDED)),
                )
              : Container(height: 220, color: const Color(0xFFEDEDED)),
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
              money(appliedPrice),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            if (old > appliedPrice)
              Text(
                money(old),
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
        if (coupon != null) _CouponInline(coupon: coupon),
        const SizedBox(height: 16),
        const Text('MÃ´ táº£', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(p.description ?? 'MÃ´ táº£ demo sáº£n pháº©m.'),
        if (p.categories.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Danh má»¥c',
              style: TextStyle(fontWeight: FontWeight.w700)),
          Wrap(
            spacing: 8,
            children: p.categories
                .map(
                  (c) => Chip(
                    label: Text(c.name),
                    backgroundColor: Colors.grey.shade200,
                  ),
                )
                .toList(),
          ),
        ],
        if (p.badges.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Badges', style: TextStyle(fontWeight: FontWeight.w700)),
          Wrap(
            spacing: 8,
            children: p.badges
                .map(
                  (b) => Chip(
                    label: Text(b.label),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _CouponInline extends StatelessWidget {
  final Coupon coupon;
  const _CouponInline({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final isHot = coupon.badges.any(
          (b) => b.key.toUpperCase() == 'HOT',
        ) ||
        (coupon.priority ?? 0) >= 80;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon.sourceId ?? 'ToÃ n sÃ n',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (isHot)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                'Code: ${coupon.code}',
                primary: true,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: coupon.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ÄÃ£ copy mÃ£')),
                  );
                },
              ),
              if (coupon.minSpend != null)
                _chip(context, 'Min ${money(coupon.minSpend!)}'),
              if (coupon.maxDiscount != null)
                _chip(context, 'Max ${money(coupon.maxDiscount!)}'),
              _chip(
                context,
                coupon.isPercent
                    ? 'Giáº£m ${coupon.discountValue}%'
                    : 'Giáº£m ${money(coupon.discountValue)}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'HSD: ${_fmtDate(coupon.endAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: coupon.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ÄÃ£ copy mÃ£')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy mÃ£'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openLink(context),
                  icon: const Icon(Icons.launch, size: 18),
                  label: const Text('DÃ¹ng mÃ£'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VoucherDetailScreen(couponId: coupon.id),
                  ),
                );
              },
              child: const Text('Xem chi tiáº¿t mÃ£'),
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
        ? Theme.of(ctx).colorScheme.primary.withValues(alpha: .1)
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

  Future<void> _openLink(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final link = coupon.deeplink ?? coupon.trackingLink;
    if (link == null || link.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Chưa có liên kết dùng mã')),
      );
      return;
    }
    final canLaunchLink = await canLaunchUrlString(link);
    if (!canLaunchLink) {
      messenger.showSnackBar(
        SnackBar(content: Text('Không mở được: ')),
      );
      return;
    }
    await launchUrlString(link, mode: LaunchMode.externalApplication);
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    String two(int x) => x < 10 ? '0$x' : '$x';
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
