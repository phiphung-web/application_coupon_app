import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;
  const Responsive({super.key, required this.mobile, required this.desktop});
  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width >= 900;
  @override
  Widget build(BuildContext context) =>
      isDesktop(context) ? desktop : mobile;
}
