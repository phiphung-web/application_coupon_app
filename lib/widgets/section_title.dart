import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;
  const SectionTitle(this.title, {super.key, this.onMore});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        if (onMore != null)
          TextButton(onPressed: onMore, child: const Text('Xem thêm')),
      ],
    );
  }
}
