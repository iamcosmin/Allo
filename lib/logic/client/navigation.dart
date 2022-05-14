import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';

var navigatorKey = GlobalKey<NavigatorState>();
const _kDefaultNavigatorError =
    '''There is neither a BuildContext, not a GlobalKey<NavigatorState>.
    This can happen if you did not pass a BuildContext, or you haven't initialized the key in 
    MaterialApp.''';

class Navigation {
  void push({
    required Widget route,
    BuildContext? context,
  }) {
    final pageRoute = MaterialPageRoute(builder: (_) => route);
    if (context != null) {
      context.navigator.push(pageRoute);
    } else if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(pageRoute);
    } else {
      throw Exception(_kDefaultNavigatorError);
    }
  }

  void pushPermanent({
    required Widget route,
    BuildContext? context,
  }) {
    final pageRoute = MaterialPageRoute(builder: (_) => route);
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        pageRoute,
        (route) => false,
      );
    } else if (navigatorKey.currentState != null) {
      navigatorKey.currentState
          ?.pushAndRemoveUntil(pageRoute, (route) => false);
    } else {
      throw Exception(_kDefaultNavigatorError);
    }
  }
}
