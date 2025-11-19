import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/money.dart';
import '../../data/impl/coupon_repo_remote.dart';
import '../../data/repo/coupon_repo.dart';
import '../../models/coupon.dart';

class VoucherDetailScreen extends StatefulWidget {
  final int couponId;
  const VoucherDetailScreen({super.key, required this.couponId});

  @override
  State<VoucherDetailScreen> createState() => _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends State<VoucherDetailScreen> {
  final CouponRepo _repo = CouponRepoRemote();
  Coupon? _coupon;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await _repo.getById(widget.couponId);
    if (!mounted) return;
    setState(() {
      _coupon = c;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_coupon == null) {
      return const Center(child: Text('Không tìm thấy mã'));
    }

    final c = _coupon!;
    final isHot = c.badges.any((b) => b.key.toUpperCase() == 'HOT') ||
        (c.priority ?? 0) >= 80;
    final appliedSource =
        c.sourceName ?? (c.sourceId != null ? 'Nguồn #${c.sourceId}' : 'Toàn sàn');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (c.imageUrl != null && c.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              c.imageUrl!,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 200, color: const Color(0xFFEDEDED)),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                c.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã copy mã')),
                );
              },
            ),
            if (c.minSpend != null) _chip(context, 'Min ${money(c.minSpend!)}'),
            if (c.maxDiscount != null)
              _chip(context, 'Max ${money(c.maxDiscount!)}'),
            _chip(
              context,
              c.isPercent
                  ? 'Giảm ${c.discountValue}%'
                  : 'Giảm ${money(c.discountValue)}',
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Hiệu lực: ${_fmtDate(c.startAt)} → ${_fmtDate(c.endAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Divider(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: c.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã copy mã')),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy mã'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openLink(context, c),
                icon: const Icon(Icons.launch, size: 18),
                label: const Text('Dùng mã'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Áp dụng tại: $appliedSource'),
        if (c.categories.isNotEmpty)
          Text(
            'Danh mục áp dụng: ${c.categories.map((cat) => cat.name).join(', ')}',
          ),
        const SizedBox(height: 16),
        const Text(
          'Điều kiện & điều khoản',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Ví dụ: Có thể yêu cầu đơn tối thiểu '
          '${c.minSpend != null ? money(c.minSpend!) : 'không có'}. '
          'Mức giảm tối đa '
          '${c.maxDiscount != null ? money(c.maxDiscount!) : 'không giới hạn'}.',
        ),
      ],
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

  Future<void> _openLink(BuildContext context, Coupon coupon) async {
    final messenger = ScaffoldMessenger.of(context);
    final link = coupon.dealUrl ?? coupon.deeplink ?? coupon.trackingLink;
    if (link == null || link.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Chưa có liên kết dùng mã')),
      );
      return;
    }
    final canLaunchLink = await canLaunchUrlString(link);
    if (!canLaunchLink) {
      messenger.showSnackBar(
        SnackBar(content: Text('Không mở được: $link')),
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
