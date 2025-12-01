import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String? src;
  final double? w, h;
  final BoxFit fit;
  final String placeholder;
  const AppImage(
    this.src, {
    super.key,
    this.w,
    this.h,
    this.fit = BoxFit.cover,
    this.placeholder = 'assets/images/OIP.webp',
  });

  bool get _isHttp =>
      src != null &&
      (src!.startsWith('http://') || src!.startsWith('https://'));
  @override
  Widget build(BuildContext context) {
    if (_isHttp) {
      return Image.network(
        src!,
        width: w,
        height: h,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            Image.asset(placeholder, width: w, height: h, fit: fit),
      );
    }
    return Image.asset(src ?? placeholder, width: w, height: h, fit: fit);
  }
}
