import 'package:allo/interface/home/home.dart';
import 'package:allo/interface/login/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final navigationProvider =
    Provider<NavigationRepository>((ref) => NavigationRepository());

class NavigationRepository {
  to(BuildContext context, Widget route) {
    return Navigator.push(
        context, CupertinoPageRoute(builder: (context) => route));
  }

  Future _returnFirebaseUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? firebaseUser = auth.currentUser;

    if (firebaseUser == null) {
      firebaseUser = await auth.authStateChanges().first;
    }

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
