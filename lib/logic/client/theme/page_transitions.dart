import 'package:allo/components/page_route.dart';
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
typedef _DefaultPageTransitionsBuilder = SwipeablePageTransitionsBuilder;

/// Gets the [PageTransitionsTheme] for the app.
/// If [reducedMotion] is true, [_NoPageTransitionsBuilder] will be the default,
/// otherwise, [_DefaultPageTransitionsBuilder].
PageTransitionsTheme getPageTransitionsTheme({required bool reducedMotion}) {
  if (!reducedMotion) {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _DefaultPageTransitionsBuilder(),
        TargetPlatform.fuchsia: _DefaultPageTransitionsBuilder(),
        TargetPlatform.iOS: _DefaultPageTransitionsBuilder(),
        TargetPlatform.linux: _DefaultPageTransitionsBuilder(),
        TargetPlatform.macOS: _DefaultPageTransitionsBuilder(),
        TargetPlatform.windows: _DefaultPageTransitionsBuilder(),
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
