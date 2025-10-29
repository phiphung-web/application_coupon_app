class Voucher {
  final String id;
  final String title;
  final String image;
  final DateTime? expireAt;
  final int? quantity;
  final bool isHot;

  Voucher({
    required this.id,
    required this.title,
    required this.image,
    this.expireAt,
    this.quantity,
    this.isHot = false,
  });
}
