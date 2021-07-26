import 'package:allo/interface/home/home.dart';
import 'package:allo/interface/login/welcome.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final navigationProvider =
    Provider<NavigationRepository>((ref) => NavigationRepository());

class NavigationRepository {
  Future to(BuildContext context, Widget route) {
    return Navigator.push(
        context, CupertinoPageRoute(builder: (context) => route));
  }

  Future toPermanent(BuildContext context, Widget route) {
    return Navigator.pushAndRemoveUntil(context,
        CupertinoPageRoute(builder: (context) => route), (route) => false);
  }

  Future push(BuildContext context, Widget route,
      SharedAxisTransitionType transitionType) {
    return Navigator.push(
      context,
      PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => route,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              fillColor: context.read(Repositories.colors).nonColors,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          }),
    );
  }

  Future pushPermanent(BuildContext context, Widget route,
      SharedAxisTransitionType transitionType) {
    return Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => route,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: transitionType,
                fillColor: context.read(colorsProvider).nonColors,
                child: child,
              );
            }),
        (route) => false);
  }

  Future _returnFirebaseUser() async {
    var auth = FirebaseAuth.instance;
    var firebaseUser = auth.currentUser;

    firebaseUser ??= await auth.authStateChanges().first;

    return firebaseUser;
  }

  Future decideIfAuthenticated() async {
    dynamic firebaseUser = await _returnFirebaseUser();
    if (firebaseUser == null) {
      return Welcome();
    } else {
      return Home();
    }
  }
}
