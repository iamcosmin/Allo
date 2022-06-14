import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingContainer extends StatelessWidget {
  const LoadingContainer({
    required this.height,
    required this.width,
    super.key,
  });
  final double height;
  final double width;

  @override
  Widget build(context) {
    final colors = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colors.onInverseSurface,
      highlightColor: colors.inverseSurface.withOpacity(0.5),
      child: Container(
        height: height,
        width: width,
        color: colors.inverseSurface.withOpacity(0.5),
      ),
    );
  }
}
