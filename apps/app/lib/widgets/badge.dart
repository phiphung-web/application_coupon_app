import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final String text;
  final Color? color;
  const Badge(this.text, {super.key, this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: (color ?? Colors.black87),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
  );
}
