import 'package:allo/core/error_codes.dart';
import 'package:allo/interface/home/home.dart';
import 'package:allo/interface/login/signup/choose_username.dart';
import 'package:allo/interface/login/signup/verify_email.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authProvider = Provider<AuthRepository>((ref) => AuthRepository());

class AuthRepository {
  /// Initialises Firebase components.
  Future initFirebase() async {
    await Firebase.initializeApp();
  }

  Future returnUserDetails() async {
    return FirebaseAuth.instance.currentUser;
  }

  /// Signs in the user with the provided email and password.
  Future login(String _email, String _password, BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      Navigator.pushAndRemoveUntil(context,
          CupertinoPageRoute(builder: (context) => Home()), (route) => false);
      return ErrorCodes.succes;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return ErrorCodes.invalidEmail;
      } else if (e.code == 'user-disabled') {
        return ErrorCodes.userDisabled;
      } else if (e.code == 'user-not-found') {
        return ErrorCodes.userNotFound;
      } else if (e.code == 'wrong-password') {
        return ErrorCodes.wrongPassword;
      } else {
        return ErrorCodes.noAccount;
      }
    }
  }

  Future signup(String name, String email, String password1, String password2,
      BuildContext context) async {
    if (name != "" && email != "" && password1 != "" && password2 != "") {
      if (password1 == password2) {
        String matchedPassword = password2;
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email, password: matchedPassword);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .set({'name': name, 'isVerified': false, 'email': email});
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => VerifyEmail()),
              (route) => false);
          return ErrorCodes.succes;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            return ErrorCodes.emailAlreadyInUse;
          } else if (e.code == 'invalid-email') {
            return ErrorCodes.invalidEmail;
          } else if (e.code == 'operation-not-allowed') {
            return ErrorCodes.operationNotAllowed;
          } else if (e.code == 'weak-password') {
            return ErrorCodes.weakPassword;
          } else {
            return ErrorCodes.nullFields;
          }
        }
      } else {
        return ErrorCodes.passwordMismatch;
      }
    } else {
      return ErrorCodes.nullFields;
    }
  }

  Future sendEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  Future isVerified(BuildContext context) async {
    bool isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    await FirebaseAuth.instance.currentUser?.reload();
    if (isVerified) {
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => ChooseUsername()),
          (route) => false);
      return ErrorCodes.succes;
    } else if (!isVerified) {
      return ErrorCodes.stillNotVerified;
    }
  }

  Future configureUsername(String _username, BuildContext context) async {
    DocumentSnapshot usernames = await FirebaseFirestore.instance
        .collection('users')
        .doc('usernames')
        .get();
    if (usernames.data()![_username] != null) {
      return "$_username nu este disponibil!";
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('usernames')
          .update({
        FirebaseAuth.instance.currentUser!.uid: _username,
      });
      Navigator.pushAndRemoveUntil(context,
          CupertinoPageRoute(builder: (context) => Home()), (route) => false);
      return "";
    }
  }

  Future signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw Exception('Something is wrong...');
    }
  }
}
