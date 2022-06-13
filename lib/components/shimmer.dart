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
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.onInverseSurface,
      highlightColor:
          Theme.of(context).colorScheme.inverseSurface.withOpacity(0.5),
      child: Container(
        height: height,
        width: width,
        color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.5),
      ),
    );
  }
}
