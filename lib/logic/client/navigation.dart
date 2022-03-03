import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class Navigation {
  Future push({
    required BuildContext context,
    required Widget route,
    @Deprecated('Whether this is true or false, the same transition will be used.')
        bool login = false,
  }) {
    final pageRoute = MaterialPageRoute(builder: (_) => route);
    return Navigator.of(context).push(pageRoute);
  }

  @Deprecated('Use pushPermanent.')
  Future pushAndRemoveUntilHome(
      {required BuildContext context, required Widget route}) {
    return Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => route),
      (_) => false,
    );
  }

  Future pushPermanent({
    required BuildContext context,
    required Widget route,
    bool login = false,
  }) {
    Route? pageRoute;
    if (login) {
      pageRoute = PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: route,
            fillColor: Theme.of(context).colorScheme.surface,
          );
        },
      );
    } else {
      pageRoute = MaterialPageRoute(builder: (_) => route);
    }
    return Navigator.of(context).pushAndRemoveUntil(
      pageRoute,
      (route) => false,
    );
  }
}
