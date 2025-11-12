import 'package:flutter/material.dart';
import '../../models/coupon.dart';
import '../../data/repo/coupon_repo.dart';
import '../../data/impl/coupon_repo_remote.dart';
import '../../widgets/coupon_list_item.dart';
import '../detail/voucher_detail_screen.dart';

class HotCouponsScreen extends StatefulWidget {
  const HotCouponsScreen({super.key});
  @override
  State<HotCouponsScreen> createState() => _HotCouponsScreenState();
}

class _HotCouponsScreenState extends State<HotCouponsScreen> {
  final CouponRepo _repo = CouponRepoRemote();
  List<Coupon> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.hot(limit: 200);
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mã hot')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) => CouponListItem(
                coupon: _items[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VoucherDetailScreen(couponId: _items[i].id),
                  ),
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: _items.length,
            ),
    );
  }
}
