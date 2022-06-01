import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// A [PageTransitionsBuilder] that does not have any animation.
/// Useful when using reduced motion.
class _NoPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// The default [PageTransitionsBuilder], a horizontal scale that, if the device has a
/// touchscreen, swiping right on the screen will go back to the previous screen.

/// Gets the [PageTransitionsTheme] for the app.
/// If [reducedMotion] is true, [_NoPageTransitionsBuilder] will be the default,
/// otherwise, [_DefaultPageTransitionsBuilder].
PageTransitionsTheme getPageTransitionsTheme({
  required bool reducedMotion,
  required Color fillColor,
}) {
  final sharedAxisTransition = SharedAxisPageTransitionsBuilder(
    transitionType: SharedAxisTransitionType.horizontal,
    fillColor: fillColor,
  );
  if (!reducedMotion) {
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: sharedAxisTransition,
        TargetPlatform.fuchsia: const ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: sharedAxisTransition,
        TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: sharedAxisTransition,
      },
    );
  } else {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _NoPageTransitionsBuilder(),
        TargetPlatform.fuchsia: _NoPageTransitionsBuilder(),
        TargetPlatform.iOS: _NoPageTransitionsBuilder(),
        TargetPlatform.linux: _NoPageTransitionsBuilder(),
        TargetPlatform.macOS: _NoPageTransitionsBuilder(),
        TargetPlatform.windows: _NoPageTransitionsBuilder(),
      },
    );
  }
}
