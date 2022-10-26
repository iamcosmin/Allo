import 'package:flutter/cupertino.dart';

class SliverCenter extends StatelessWidget {
  const SliverCenter({
    required this.child,
    super.key,
  });
  final Widget child;

  @override
  Widget build(context) {
    return SliverFillRemaining(
      child: Center(
        child: child,
      ),
    );
  }
}
