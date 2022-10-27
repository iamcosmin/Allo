import 'package:flutter/material.dart';

enum Direction { vertical, horizontal }

/// A widget to use instead of bottom padding when you want to space components.
class Space extends StatelessWidget {
  const Space(this.factor, {this.direction = Direction.vertical, super.key});
  final double factor;
  final Direction direction;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: direction == Direction.vertical ? factor * 10 : null,
      width: direction == Direction.horizontal ? factor * 10 : null,
    );
  }
}
