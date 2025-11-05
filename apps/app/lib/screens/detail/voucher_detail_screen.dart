import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/money.dart';
import '../../core/pricing.dart';
import '../../models/coupon.dart';
import '../../models/product.dart';

import '../../data/repo/coupon_repo.dart';
import '../../data/repo/product_repo.dart';
import '../../data/impl/coupon_repo_mock.dart';
import '../../data/impl/product_repo_mock.dart';

import '../../widgets/app_image.dart';
import '../../widgets/product_card.dart';

class VoucherDetailScreen extends StatefulWidget {
  final String couponId; // id dạng String
  const VoucherDetailScreen({super.key, required this.couponId});

  @override
  State<VoucherDetailScreen> createState() => _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends State<VoucherDetailScreen> {
  final CouponRepo _couponRepo = CouponRepoMock();
  final ProductRepo _productRepo = ProductRepoMock();

  Coupon? _coupon;
  List<Product> _related = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final c = await _couponRepo.getById(widget.couponId);

    // lấy một pool sản phẩm rồi lọc theo khả năng áp mã
    List<Product> related = [];
    if (c != null) {
      // lấy ~60 sp đủ để demo
      final p1 = await _productRepo.list(
        page: 1,
        pageSize: 60,
        categoryId: c.categoryId,
      );
      final pool = p1.data;
      related = pool
          .where(
            (p) => bestForProduct(p, [c]).discount > 0,
          ) // dùng logic từ pricing.dart
          .take(12)
          .toList();
    }

    if (!mounted) return;
    setState(() {
      _coupon = c;
      _related = related;
      _loading = false;
    });
  }

  void _copy(String text, {String toast = 'Đã copy'}) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toast)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết mã')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_coupon == null)
          ? const Center(child: Text('Không tìm thấy mã'))
          : _buildBody(_coupon!),
    );
  }

  Widget _buildBody(Coupon c) {
    final isHot = (c.tags.contains('hot')) || ((c.priority ?? 0) >= 80);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (c.imageUrl != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppImage(
                  c.imageUrl,
                  w: double.infinity,
                  h: 180,
                  fit: BoxFit.cover,
                ),
              ),
              if (isHot)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
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
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 12),

        // Tiêu đề
        Text(c.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Shop: ${c.shopId ?? "-"}  •  HSD: ${_fmtDate(c.expiredAt)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: 12),
        // Chip thông tin nhanh
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip(
              context,
              'Code: ${c.code}',
              primary: true,
              onTap: () => _copy(c.code, toast: 'Đã copy mã'),
            ),
            if (c.minSpend != null) _chip(context, 'Min ${money(c.minSpend!)}'),
            if (c.maxDiscount != null)
              _chip(context, 'Max ${money(c.maxDiscount!)}'),
            _chip(context, _discountLabel(c)),
          ],
        ),

        const SizedBox(height: 12),
        // Nút hành động
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _copy(c.code, toast: 'Đã copy mã'),
              child: const Text('Copy mã'),
            ),
            const SizedBox(width: 12),
            if (c.deeplink != null || c.trackingLink != null)
              ElevatedButton(
                onPressed: () {
                  final link = c.deeplink ?? c.trackingLink!;
                  _copy(link, toast: 'Đã copy liên kết');
                  // Có thể dùng url_launcher để mở link nếu muốn
                },
                child: const Text('Dùng ngay'),
              ),
          ],
        ),

        const SizedBox(height: 16),
        const Text(
          'Điều kiện áp dụng',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        if ((c.applicableTypes ?? const []).isEmpty && c.minSpend == null)
          const Text('Không có điều kiện bổ sung.')
        else ...[
          if (c.minSpend != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• Đơn tối thiểu: ${money(c.minSpend!)}'),
            ),
          if ((c.applicableTypes ?? const []).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• Áp dụng cho: ${(c.applicableTypes!).join(", ")}'),
            ),
          if (c.categoryId != null && c.categoryId != 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• Danh mục áp dụng: #${c.categoryId}'),
            ),
          if (c.expiredAt != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• Hết hạn: ${_fmtDate(c.expiredAt)}'),
            ),
        ],

        const SizedBox(height: 16),
        if (_related.isNotEmpty) ...[
          const Text(
            'Sản phẩm có thể áp dụng',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          // Hiển thị dạng lưới 2 cột cho đẹp
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _related.length,
            itemBuilder: (_, i) => ProductCard(product: _related[i]),
          ),
        ],
      ],
    );
  }

  // ===== helpers =====
  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    String two(int x) => x < 10 ? '0$x' : '$x';
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  String _discountLabel(Coupon c) {
    final t = (c.discountType).toUpperCase();
    if (t == 'PERCENT') return 'Giảm ${c.discountValue}%';
    return 'Giảm ${money(c.discountValue)}';
  }

  Widget _chip(
    BuildContext ctx,
    String text, {
    bool primary = false,
    VoidCallback? onTap,
  }) {
    final bg = primary
        ? Theme.of(ctx).colorScheme.primary.withOpacity(.1)
        : Theme.of(ctx).colorScheme.surfaceVariant.withOpacity(.75);
    final fg = primary
        ? Theme.of(ctx).colorScheme.primary
        : Theme.of(ctx).colorScheme.onSurfaceVariant;
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
}
