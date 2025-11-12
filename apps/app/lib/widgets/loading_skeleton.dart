import 'package:flutter/material.dart';

class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: borderRadius,
      ),
    );
  }
}

List<Widget> buildGridSkeleton({
  required int count,
  double width = double.infinity,
  double height = 160,
}) {
  return List.generate(
    count,
    (_) => LoadingSkeleton(width: width, height: height),
  );
}
