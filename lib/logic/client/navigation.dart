import 'package:allo/logic/client/theme/animations.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Material3PageRoute extends MaterialPageRoute {
  Material3PageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration =>
      Duration(milliseconds: const Motion().animationDuration.short4Ms.toInt());
}

class Navigation {
  const Navigation._();

  static final navigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'master_navigator_key',
  );
  static const _kDefaultNavigatorError =
      '''There is neither a BuildContext, not a GlobalKey<NavigatorState>.
    This can happen if you did not pass a BuildContext, or you haven't initialized the key in 
    MaterialApp.''';

  static PageRoute pageRoute(Widget route) {
    switch (ThemeData().platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return Material3PageRoute(
          builder: (_) => route,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoPageRoute(
          builder: (_) => route,
        );
    }
  }

  static void pop({BuildContext? context}) async {
    if (context != null) {
      context.navigator.pop();
    } else if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pop();
    } else {
      throw Exception(_kDefaultNavigatorError);
    }
  }

  static void push({
    required Widget route,
    BuildContext? context,
  }) {
    if (context != null) {
      context.navigator.push(pageRoute(route));
    } else if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(pageRoute(route));
    } else {
      throw Exception(_kDefaultNavigatorError);
    }
  }

  static void pushReplacement(Widget route, {BuildContext? context}) {
    if (context != null) {
      context.navigator.pushReplacement(pageRoute(route));
    } else if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushReplacement(pageRoute(route));
    } else {
      throw Exception(_kDefaultNavigatorError);
    }
  }

  static void pushPermanent({
    required Widget route,
    BuildContext? context,
  }) {
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        pageRoute(route),
        (route) => false,
      );
    } else if (navigatorKey.currentState != null) {
      navigatorKey.currentState
          ?.pushAndRemoveUntil(pageRoute(route), (route) => false);
    } else {
      throw Exception(_kDefaultNavigatorError);
    }
  }
}
