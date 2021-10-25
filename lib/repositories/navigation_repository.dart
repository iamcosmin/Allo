import 'package:allo/components/scale_page_transition.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

final navigationProvider =
    Provider<NavigationRepository>((ref) => NavigationRepository());

class NavigationRepository {
  Future push(BuildContext context, Widget route, {bool? maintainState}) {
    return Navigator.push(
        context,
        MaterialWithModalsPageRoute(
            builder: (context) => route, maintainState: maintainState ?? true));
  }

  @Deprecated('message')
  Future pushPermanent(BuildContext context, Widget route,
      SharedAxisTransitionType transitionType) {
    return Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => route,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return ScalePageTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            }),
        (route) => false);
  }
}
