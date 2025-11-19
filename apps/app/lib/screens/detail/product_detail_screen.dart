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
import '../../widgets/loading_skeleton.dart';
import '../../widgets/product_grid_card.dart';
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
  bool _loadingRelated = false;
  List<Product> _related = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadingRelated = true;
    });

    final product = await _pRepo.getById(widget.productId);
    PricingResult? best;
    if (product != null) {
      if (product.bestDeal != null) {
        best = PricingResult(
          finalPrice: product.bestDeal!.after,
          discountAmount: product.bestDeal!.saved,
          coupon: product.bestDeal!.coupon,
        );
      } else {
        final coupons = (await _cRepo.list(pageSize: 200)).data;
        best = bestForProduct(product, coupons);
      }
    }
    final related = product != null ? await _fetchRelated(product) : <Product>[];

    if (!mounted) return;
    setState(() {
      _product = product;
      _best = best;
      _related = related;
      _loading = false;
      _loadingRelated = false;
    });
  }

  Future<List<Product>> _fetchRelated(Product base) async {
    try {
      final catId = base.categories.isNotEmpty ? base.categories.first.id : null;
      if (catId == null && base.sourceId == null) return const [];
      final res = await _pRepo.list(
        page: 1,
        pageSize: 10,
        categoryId: catId,
        shopId: base.sourceId,
      );
      return res.data.where((p) => p.id != base.id).toList();
    } catch (_) {
      return const [];
    }
  }

  void _handleHomePressed(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    } else {
      _load();
    }
  }

  Future<void> _openProductLink(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Liên kết không hợp lệ')));
      return;
    }
    final canLaunch = await canLaunchUrlString(url);
    if (!canLaunch) {
      messenger.showSnackBar(
        SnackBar(content: Text('Không mở được liên kết: $url')),
      );
      return;
    }
    await launchUrlString(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Về trang chủ',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => _handleHomePressed(context),
          ),
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? const Center(child: Text('Không tìm thấy sản phẩm'))
              : _buildBody(_product!, _best?.coupon),
    );
  }

  Widget _buildBody(Product p, Coupon? coupon) {
    final appliedPrice = _best?.finalPrice ?? p.priceEffective;
    final old = p.priceOriginal;
    final pct = old > 0 ? ((old - appliedPrice) * 100 ~/ old) : 0;

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
        const SizedBox(height: 12),
        Text(
          p.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              money(appliedPrice),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
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
        const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(p.description ?? 'Chưa có mô tả chi tiết cho sản phẩm này.'),
        const SizedBox(height: 16),
        _buildSourceCard(p),
        if (p.categories.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Thuộc danh mục', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: p.categories
                .map(
                  (cat) => Chip(
                    label: Text(cat.name),
                    avatar: const Icon(Icons.label_outline, size: 16),
                  ),
                )
                .toList(),
          ),
        ],
        if (_loadingRelated) ...[
          const SizedBox(height: 24),
          const Text('Sản phẩm liên quan', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, __) => const LoadingSkeleton(width: 180, height: 220),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: 4,
            ),
          ),
        ] else if (_related.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('Sản phẩm liên quan', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) => SizedBox(
                width: 180,
                child: ProductGridCard(
                  product: _related[index],
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(productId: _related[index].id),
                    ),
                  ),
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: _related.length,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSourceCard(Product p) {
    final hasSource =
        p.sourceName != null || p.sourceId != null || (p.itemUrl != null && p.itemUrl!.isNotEmpty);
    if (!hasSource) return const SizedBox.shrink();
    final sourceLabel = p.sourceName ?? (p.sourceId != null ? 'Nguồn #${p.sourceId}' : 'Nhiều nguồn');
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: ListTile(
        leading: const Icon(Icons.storefront_outlined),
        title: Text(sourceLabel),
        subtitle: p.itemUrl != null ? Text(p.itemUrl!) : null,
        trailing: p.itemUrl != null
            ? IconButton(
                tooltip: 'Mở liên kết sản phẩm',
                icon: const Icon(Icons.open_in_new),
                onPressed: () => _openProductLink(p.itemUrl!),
              )
            : null,
      ),
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
                      coupon.sourceName ?? (coupon.sourceId != null ? 'Nguồn #${coupon.sourceId}' : 'Toàn sàn'),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
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
                'Code: ${coupon.code}',
                primary: true,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: coupon.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã copy mã')),
                  );
                },
              ),
              if (coupon.minSpend != null) _chip(context, 'Min ${money(coupon.minSpend!)}'),
              if (coupon.maxDiscount != null) _chip(context, 'Max ${money(coupon.maxDiscount!)}'),
              _chip(
                context,
                coupon.isPercent ? 'Giảm ${coupon.discountValue}%' : 'Giảm ${money(coupon.discountValue)}',
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VoucherDetailScreen(couponId: coupon.id),
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
    final bg = primary ? Theme.of(ctx).colorScheme.primary.withValues(alpha: .1) : Colors.grey.shade200;
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
