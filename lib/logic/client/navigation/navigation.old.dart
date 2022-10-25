import 'dart:developer';

import 'package:allo/logic/client/navigation/routing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _kNoNavigatorException = '''
There is no possible way to navigate in the current scope.
This is because you did not provide the navigator key, or you did not provide the optional widget context
if you are out of scope.

The simple solution would be to irrigate the method with a BuildContext from the current scope, as reusing a navigatorKey
is not possible.
''';

@Deprecated(
  'After https://github.com/flutter/flutter/issues/111961 will be fixed, this class will be removed. Please use go_router.',
)
class Navigation {
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static GoRouter get contextless {
    if (rootNavigatorKey.currentContext != null) {
      return GoRouter.of(rootNavigatorKey.currentContext!);
    } else {
      throw Exception(_kNoNavigatorException);
    }
  }

  static PageRoute _pageRoute(Widget route) {
    switch (ThemeData().platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return MaterialPageRoute(
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
    log(
      'Note that this way of navigating is obsolete. Please use Navigator 2.0.',
      name: 'Navigation',
    );
    if (context != null) {
      return Navigator.of(context);
    } else if (rootNavigatorKey.currentState != null) {
      return rootNavigatorKey.currentState!;
    } else {
      throw Exception(_kNoNavigatorException);
    }
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
}
