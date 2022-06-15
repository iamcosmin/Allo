import 'package:allo/logic/client/theme/slide_page_transition.dart';
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
  const sharedAxisTransition = SlidePageTransitionsBuilder();
  if (!reducedMotion) {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: sharedAxisTransition,
        TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: sharedAxisTransition,
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
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
