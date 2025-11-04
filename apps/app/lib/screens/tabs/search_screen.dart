import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/voucher_card.dart';
import '../../data/impl/coupon_repo_mock.dart';
import '../detail/voucher_detail_screen.dart';
import '../../data/impl/search_history_local.dart';
import '../../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final repo = CouponRepoMock();
  final history = SearchHistoryLocal();
  final ctrl = TextEditingController();

  List results = [];
  List<String> recent = [];
  bool loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final h = await history.get();
    if (mounted) setState(() => recent = h);
  }

  Future<void> _searchNow(String q) async {
    setState(() => loading = true);
    if (q.trim().isNotEmpty) await history.add(q);
    final data = await repo.list(q: q, limit: 20);
    setState(() {
      results = data;
      loading = false;
    });
    _loadHistory();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _searchNow(q));
  }

  @override
  Widget build(BuildContext context) {
    final showRecent =
        !loading && results.isEmpty && ctrl.text.isEmpty && recent.isNotEmpty;

    return SafeArea(
      child: Column(
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
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _onChanged,
            onSubmitted: _searchNow,
          ),
          const SizedBox(height: 12),
          if (loading) const LinearProgressIndicator(),

          if (showRecent)
            SizedBox(
              height: 40,
              child: ListView.separated(
                primary: false,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: recent.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Row(
                      children: const [
                        Icon(Icons.history),
                        SizedBox(width: 6),
                        Text('Gần đây'),
                      ],
                    );
                  }
                  final k = recent[i - 1];
                  return ActionChip(
                    label: Text(k),
                    onPressed: () {
                      ctrl.text = k;
                      _searchNow(k);
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 8),
          Expanded(
            child: results.isEmpty && !loading
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'Không có kết quả',
                    subtitle: 'Thử từ khóa khác, ví dụ: freeship, 50%, shopee',
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final c = results[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: VoucherCard(
                          title: c.title,
                          code: c.code,
                          shop: c.shopId,
                          endAt: c.endAt,
                          imageUrl: c.imageUrl?.startsWith('http') == true
                              ? c.imageUrl
                              : null,
                          badge:
                              (c.tags.contains('hot') ||
                                  (c.priority ?? 0) >= 80)
                              ? 'HOT'
                              : null,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  VoucherDetailScreen(couponId: c.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
