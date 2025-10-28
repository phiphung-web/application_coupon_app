import 'package:flutter/material.dart';
import '../../widgets/voucher_card.dart';
import '../../data/impl/coupon_repo_mock.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final repo = CouponRepoMock();
  final ctrl = TextEditingController();
  List results = [];
  bool loading = false;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    setState(() => loading = true);
    final data = await repo.list(q: q, limit: 20);
    setState(() {
      results = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Tìm voucher, shop, mã…',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFF1F3F5),
            border: OutlineInputBorder(
              borderSide: BorderSide.none, borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: _search,
        ),
        const SizedBox(height: 12),
        if (loading) const LinearProgressIndicator(),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, i) {
              final c = results[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VoucherCard(
                  title: c.title, code: c.code, shop: c.shopId,
                  endAt: c.endAt, imageUrl: c.imageUrl,
                  badge: (c.tags.contains('hot') || (c.priority ?? 0) >= 80) ? 'HOT' : null,
                  onCopy: () {}, onUse: () {}, onFav: () {},
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
