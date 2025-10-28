// import 'package:flutter/material.dart';
// import '../models/voucher.dart';
// import '../models/category.dart';

// class ApiService {
//   static List<Category> getCategories() => [
//         Category(id: "fashion", name: "Thời trang", iconAsset: "assets/cat_fashion.png"),
//         Category(id: "electronics", name: "Điện tử", iconAsset: "assets/cat_elec.png"),
//         Category(id: "food", name: "Ăn uống", iconAsset: "assets/cat_food.png"),
//         Category(id: "mom_baby", name: "Mẹ & Bé", iconAsset: "assets/cat_mombaby.png"),
//       ];

//   static List<Voucher> getHotVouchers() => [
//         Voucher(
//           id: "v1",
//           title: "Shopee giảm 20%",
//           image: "assets/shopee.webp",
//           expireAt: DateTime.now().add(const Duration(days: 3)),
//           quantity: 50,
//           isHot: true,
//         ),
//         Voucher(
//           id: "v2",
//           title: "Tiki Freeship",
//           image: "assets/tiki.png",
//           expireAt: DateTime.now().add(const Duration(hours: 40)),
//           quantity: 120,
//           isHot: true,
//         ),
//       ];

//   static List<Voucher> getAllVouchers() => [
//         ...getHotVouchers(),
//         Voucher(
//           id: "v3",
//           title: "GrabFood -10%",
//           image: "assets/grabfood.png",
//           expireAt: DateTime.now().add(const Duration(days: 10)),
//           quantity: 200,
//         ),
//       ];

//   static void onViewDetail(BuildContext context, Voucher v) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Xem chi tiết: ${v.title}")),
//     );
//   }
// }