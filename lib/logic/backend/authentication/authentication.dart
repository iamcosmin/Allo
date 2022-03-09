import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/existing/enter_password.dart';
import 'package:allo/interface/login/new/setup_name.dart';
import 'package:allo/interface/login/new/setup_password.dart';
import 'package:allo/logic/backend/authentication/user.dart';
import 'package:allo/logic/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';

Future<dynamic> _getType(Type type, String key) async {
  final prefs = await SharedPreferences.getInstance();
  dynamic condition;
  switch (type) {
    case bool:
      condition = prefs.getBool(key);
      break;
    case String:
      condition = prefs.getString(key);
      break;
    case int:
      condition = prefs.getInt(key);
      break;
    case double:
      condition = prefs.getDouble(key);
      break;
    default:
      condition = null;
  }
  return condition;
}

/// Returns a key from storage if exists, otherwise fetches the data using the fetch function.
/// Please remember that you need to return a value of the same type as the type parameter,
/// otherwise the function will fail.
Future cache(
    {required String key, required Function fetch, required Type type}) async {
  final prefs = await SharedPreferences.getInstance();
  if (await _getType(type, key) == null) {
    type == bool
        ? await prefs.setBool(key, await fetch())
        : type == String
            ? await prefs.setString(key, await fetch())
            : type == int
                ? await prefs.setInt(key, await fetch())
                : type == double
                    ? await prefs.setDouble(key, await fetch())
                    : null;
  }
  return await _getType(type, key);
}

class Authentication {
  final CurrentUser user = CurrentUser();

  Future<User?> returnUserDetails() async {
    return FirebaseAuth.instance.currentUser;
  }

  /// Checks if the user is eligible for login or signup.
  Future<bool> checkAuthenticationAbility(
      {required String email,
      required ValueNotifier<String> error,
      required BuildContext context}) async {
    final locales = S.of(context);
    try {
      FocusScope.of(context).unfocus();
      error.value = '';
      final List instance =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (instance.toString() == '[]') {
        Core.navigation.push(context: context, route: SetupName(email));
      } else if (instance.toString() == '[password]') {
        Core.navigation
            .push(context: context, route: EnterPassword(email: email));
      }
      return true;
    } catch (e) {
      error.value = locales.errorThisIsInvalid(locales.email);
      return false;
    }
  }

  //? [Login]
  /// Signs in an Allo user by email and password.
  Future<bool> signIn(
      {required String email,
      required String password,
      required BuildContext context,
      required ValueNotifier<String> error}) async {
    final locales = S.of(context);
    try {
      FocusScope.of(context).unfocus();
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-disabled':
          error.value = locales.errorUserDisabled;
          break;
        case 'wrong-password':
          error.value = locales.errorWrongPassword;
          break;
        case 'too-many-requests':
          error.value = locales.errorTooManyRequests;
          break;
        default:
          error.value = locales.errorUnknown;
          break;
      }
      return false;
    }
  }

  //? Signup
  /// Signs up the user by email and password.
  Future<bool> signUp(
      {required String email,
      required String password,
      required String confirmPassword,
      required String displayName,
      required String username,
      required ValueNotifier<String> error,
      required BuildContext context}) async {
    final locales = S.of(context);
    try {
      FocusScope.of(context).unfocus();
      if (password != '' && confirmPassword != '') {
        if (password == confirmPassword) {
          var hasUppercase = password.contains(RegExp(r'[A-Z]'));
          var hasDigits = password.contains(RegExp(r'[0-9]'));
          var hasLowercase = password.contains(RegExp(r'[a-z]'));
          var hasSpecialCharacters =
              password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
          var hasMinLength = password.length >= 8;
          if (hasUppercase &&
              hasDigits &&
              hasLowercase &&
              hasSpecialCharacters &&
              hasMinLength) {
            final user = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: email, password: password);
            await user.user!.updateDisplayName(displayName);
            final db = FirebaseFirestore.instance;
            await db.collection('users').doc(username).set({
              'name': displayName,
              'email': email,
              'uid': user.user!.uid,
              'verified': false,
            });
            await db.collection('users').doc('usernames').update({
              username: user.user!.uid,
            });
            return true;
          } else {
            error.value = locales.errorPasswordRequirements;
            return false;
          }
        } else {
          error.value = locales.errorPasswordMismatch;
          return false;
        }
      } else {
        error.value = locales.errorEmptyFields;
        return false;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'operation-not-allowed':
          error.value = locales.errorOperationNotAllowed;
      }
      return false;
    }
  }

  /// Checks if the provided username is available and is compliant with
  /// the guidelines.
  Future<bool> isUsernameCompliant(
      {required String username,
      required ValueNotifier<String> error,
      required BuildContext context,
      required String displayName,
      required String email}) async {
    final locales = S.of(context);
    final usernameReg = RegExp(r'^[a-zA-Z0-9_\.]+$');
    final navigation = Core.navigation;
    final usernamesDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc('usernames')
        .get();
    final usernames = usernamesDoc.data() as Map;
    FocusScope.of(context).unfocus();
    if (username != '') {
      if (usernameReg.hasMatch(username)) {
        if (!usernames.containsKey(username)) {
          await navigation.push(
            context: context,
            route: SetupPassword(
              displayName: displayName,
              username: username,
              email: email,
            ),
          );
          return true;
        } else {
          error.value = locales.errorUsernameTaken;
          return false;
        }
      } else {
        error.value = locales.errorThisIsInvalid(locales.username);
        return false;
      }
    } else {
      error.value = locales.errorFieldEmpty;
      return false;
    }
  }

  Future changeName(
      {required String name,
      required BuildContext context,
      required ValueNotifier<String> error}) async {
    FocusScope.of(context).unfocus();
    try {
      final auth = FirebaseAuth.instance.currentUser;
      final db = FirebaseFirestore.instance
          .collection('users')
          .doc(await user.username);
      await db.update({
        'name': name,
      });
      await auth?.updateDisplayName(name);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Core.navigation.pushPermanent(context: context, route: const InnerApp());
    } catch (e) {
      throw Exception('Something is wrong...');
    }
  }

  Future changeUsername(
      {required String username,
      required BuildContext context,
      required ValueNotifier error}) async {
    FocusScope.of(context).unfocus();
    try {
      final db = FirebaseFirestore.instance.collection('users');
      final prefs = await SharedPreferences.getInstance();
      final data = await db
          .doc(await user.username)
          .get()
          .then((value) => value.data() as Map<String, Object>);
      await db.doc(await user.username).delete();
      await db.doc(username).set(data);
      await prefs.setString('username', username);
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// Sends an email to the provided email address to verify the account.
  Future sendVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  String returnNameInitials(String name) {
    final splitedName = name.split(' ');
    final arrayOfInitials = [];
    var initials = '';
    if (splitedName.isEmpty) {
      initials = splitedName[0].substring(0, 1);
    } else {
      for (var strings in splitedName) {
        if (strings.isNotEmpty) {
          arrayOfInitials.add(strings.substring(0, 1));
        }
      }
      initials = arrayOfInitials.join('');
    }
    return initials;
  }

  @Deprecated(
      'Please use the getProfilePicture method, which returns a String to use with FirebaseImage. (gs://)')
  Future<String?> getUserProfilePicture(String uid) async {
    String? url;
    try {
      url = await FirebaseStorage.instance
          .ref()
          .child('profilePictures/$uid.png')
          .getDownloadURL();
    } on FirebaseException catch (_) {}
    return url;
  }

  /// Attention: This returns a gs:// link.
  /// This should only be used with [FirebaseImage].
  String? getProfilePicture(String id, {bool? isGroup}) {
    if (isGroup != null && isGroup) {
      return 'gs://allo-ms.appspot.com/chats/$id.png';
    } else {
      return 'gs://allo-ms.appspot.com/profilePictures/$id.png';
    }
  }

  Future sendPasswordResetEmail(
      {required String email, required BuildContext context}) async {
    FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    final locales = S.of(context);
    Core.stub.showInfoBar(
        context: context,
        icon: Icons.mail_outline,
        text: locales.resetLinkSent);
  }
}