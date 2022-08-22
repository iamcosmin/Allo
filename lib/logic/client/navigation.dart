import 'package:allo/logic/client/theme/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _kNoNavigatorException = '''
There is no possible way to navigate in the current scope.
This is because you did not provide the navigator key, or you did not provide the optional widget context
if you are out of scope.

The simple solution would be to irrigate the method with a BuildContext from the current scope, as reusing a navigatorKey
is not possible.
''';

class Navigation {
  const Navigation._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static PageRoute _pageRoute(Widget route) {
    switch (ThemeData().platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return TiramisuPageRoute(
          builder: (_) => route,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoPageRoute(
          builder: (_) => route,
        );
    }
  }

  static NavigatorState _determinePossibleNavigator(BuildContext? context) {
    if (context != null) {
      return Navigator.of(context);
    } else if (navigatorKey.currentState != null) {
      return navigatorKey.currentState!;
    } else {
      throw Exception(_kNoNavigatorException);
    }
  }

  /// Navigates to a prior accessed screen, erasing the current screen from memory.
  /// You can optionally provide a context in case that you are navigating outside the key scope.
  static void backward({BuildContext? context}) async {
    _determinePossibleNavigator(context).pop();
  }

  /// Navigates to a specific page provided into the method.
  /// You can optionally provide a context in case that you are navigating outside the key scope.
  static void forward(
    Widget route, {
    BuildContext? context,
  }) {
    _determinePossibleNavigator(context).push(_pageRoute(route));
  }

  /// Replaces the current page with the provided page.
  /// Leaves the other [Navigator] stack intact.
  ///
  /// You can optionally provide a context in case you are navigating outside the key scope.
  static void replaceCurrent(Widget route, {BuildContext? context}) {
    _determinePossibleNavigator(context).pushReplacement(_pageRoute(route));
  }

  /// Replaces the current stack with the provided page.
  /// Erases all the [Navigator] stack.
  ///
  /// You can optionally provide a context in case you are navigating outside the key scope.
  static void replaceStack({
    required Widget route,
    BuildContext? context,
  }) {
    _determinePossibleNavigator(context).pushAndRemoveUntil(
      _pageRoute(route),
      (route) => route.isFirst == true,
    );
  }
}

class TiramisuPageRoute extends MaterialPageRoute {
  TiramisuPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => Duration(
        milliseconds: const Motion().animationDuration.short4Ms.toInt(),
      );
}
