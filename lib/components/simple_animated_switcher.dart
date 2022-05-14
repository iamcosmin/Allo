import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class AnimatedSwitch extends StatelessWidget {
  const AnimatedSwitch({
    required this.child,
    this.transitionType = SharedAxisTransitionType.horizontal,
    super.key,
  });
  final Widget child;
  final SharedAxisTransitionType transitionType;
  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          fillColor: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }
}
