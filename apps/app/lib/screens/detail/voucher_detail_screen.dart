import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/coupon.dart';
import '../../data/impl/coupon_repo_mock.dart';

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

class VoucherDetailScreen extends StatefulWidget {
  final String couponId;
  const VoucherDetailScreen({super.key, required this.couponId});

  @override
  State<VoucherDetailScreen> createState() => _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends State<VoucherDetailScreen> {
  final _repo = CouponRepoMock();
  Coupon? _c;
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
      _c = c;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_c == null) return const Center(child: Text('Không tìm thấy mã'));

    final c = _c!;
    final isHot = (c.tags?.contains('hot') ?? false) || (c.priority ?? 0) >= 80;

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
        const SizedBox(height: 6),
        Text(
          'Hạn dùng: ${_fmtDate(c.expiredAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Divider(height: 24),
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
                onPressed: () async {
                  final link = c.deeplink ?? c.trackingLink;
                  if (link == null || link.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chưa có liên kết dùng mã')),
                    );
                    return;
                  }
                  if (await canLaunchUrlString(link)) {
                    await launchUrlString(
                      link,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Không mở được: $link')),
                    );
                  }
                },
                icon: const Icon(Icons.launch, size: 18),
                label: const Text('Dùng mã'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          c.shopId != null ? 'Áp dụng tại: ${c.shopId}' : 'Áp dụng: Toàn sàn',
        ),
        if (c.categoryId != null) Text('Danh mục áp dụng: #${c.categoryId}'),
        const SizedBox(height: 16),
        const Text(
          'Điều kiện & điều khoản',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Đơn demo: có thể yêu cầu tối thiểu ${c.minSpend != null ? _money(c.minSpend!) : 'không'}. '
          'Mức giảm tối đa ${c.maxDiscount != null ? _money(c.maxDiscount!) : 'không giới hạn'}.',
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
