import 'package:flutter/material.dart';
import '../screens/tabs/search_screen.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.local_offer_outlined, color: Colors.black87),
          SizedBox(width: 8),
          Text('Coupon App', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: InkWell(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  Icon(Icons.search, size: 20),
                  SizedBox(width: 8),
                  Text('Tìm voucher, shop, sản phẩm…'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 56);
}
