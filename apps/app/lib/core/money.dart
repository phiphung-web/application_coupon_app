String money(int value) {
  final formatted = value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
  return '$formatted₫';
}
