import 'package:flutter/material.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/section_title.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/voucher_card.dart';
import '../../data/impl/coupon_repo_mock.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bannerImages = const [
    'https://picsum.photos/seed/b1/1200/400',
    'https://picsum.photos/seed/b2/1200/400',
    'https://picsum.photos/seed/b3/1200/400',
  ];
  final categories = const ['Ăn uống','Đi chợ','Công nghệ','Làm đẹp','Nhà cửa'];
  final repo = CouponRepoMock();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 8),
        BannerSlider(images: bannerImages),
        const SizedBox(height: 16),

        // Categories
        const SectionTitle('Danh mục'),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.map((c) => CategoryPill(c, onTap: () {})).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Hot products
        SectionTitle('Sản phẩm hot', onMore: () {}),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 16/10, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: 4,
          itemBuilder: (_, i) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network('https://picsum.photos/seed/h$i/800/500', fit: BoxFit.cover),
                Positioned(
                  left: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                    child: const Text('HOT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Voucher list
        const SectionTitle('Mã giảm giá mới'),
        FutureBuilder(
          future: repo.list(page: 1, limit: 10),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Column(
                children: List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(height: 110, decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED), borderRadius: BorderRadius.circular(12),
                  )),
                )),
              );
            }
            final data = snapshot.data!;
            return Column(
              children: data.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VoucherCard(
                  title: c.title,
                  code: c.code,
                  shop: c.shopId,
                  endAt: c.endAt,
                  imageUrl: c.imageUrl,
                  badge: (c.tags.contains('hot') || (c.priority ?? 0) >= 80) ? 'HOT' : null,
                  onCopy: () => _copy(context, c.code),
                  onUse: () => _use(context, c.trackingLink),
                  onFav: () {},
                ),
              )).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _copy(BuildContext context, String code) async {
    // Clipboard imported on demand to keep example minimal
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã copy mã $code')));
  }

  void _use(BuildContext context, String? link) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đi tới liên kết dùng mã')));
    // TODO: launchUrl(link)
  }
}
