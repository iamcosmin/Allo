import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/main_setup.dart';
import 'package:allo/interface/login/new/setup_password.dart';
import 'package:allo/interface/login/new/setup_verification.dart';
import 'package:allo/logic/backend/authentication/errors.dart';
import 'package:allo/logic/backend/authentication/user.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
Future cache({
  required String key,
  required Function fetch,
  required Type type,
}) async {
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
  Authentication();
  final CurrentUser user = CurrentUser();

  Future<User?> returnUserDetails() async {
    return FirebaseAuth.instance.currentUser;
  }

  final stateProvider = StreamProvider<AuthState>((ref) {
    return FirebaseAuth.instance.userChanges().asyncMap((event) {
      if (event != null) {
        if (event.emailVerified) {
          return AuthState.signedIn;
        }
        return AuthState.emailNotVerified;
      }
      return AuthState.signedOut;
    });
  });

  //? [Login]
  /// Signs in an Allo user by email and password.
  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
    required ValueNotifier<String> error,
  }) async {
    try {
      FocusScope.of(context).unfocus();
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      final code = SignInError.fromString(e.code);
      switch (code) {
        case SignInError.userDisabled:
          error.value = context.locale.errorUserDisabled;
          break;
        case SignInError.wrongPassword:
          error.value = context.locale.errorWrongPassword;
          break;
        case SignInError.tooManyRequests:
          error.value = context.locale.errorTooManyRequests;
          break;
        case SignInError.invalidEmail:
          error.value = context.locale.errorThisIsInvalid(context.locale.email);
          break;
        case SignInError.userNotFound:
          error.value = context.locale.errorUserNotFount;
          break;
        case SignInError.unknownError:
          error.value = context.locale.errorUnknown;
      }
    }
  }

  //? Signup
  /// Signs up the user by email and password.
  void signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String displayName,
    required String username,
    required ValueNotifier<String?> error,
    required BuildContext context,
  }) async {
    error.value = null;
    final locales = S.of(context);
    try {
      FocusScope.of(context).unfocus();
      if (password != '' && confirmPassword != '') {
        if (password == confirmPassword) {
          final hasUppercase = password.contains(RegExp(r'[A-Z]'));
          final hasDigits = password.contains(RegExp(r'[0-9]'));
          final hasLowercase = password.contains(RegExp(r'[a-z]'));
          final hasSpecialCharacters =
              password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
          final hasMinLength = password.length >= 8;
          if (hasUppercase &&
              hasDigits &&
              hasLowercase &&
              hasSpecialCharacters &&
              hasMinLength) {
            final user =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
            await user.user!.updateDisplayName(displayName);
            final db = Database.firestore;
            await db.collection('users').doc(username).set({
              'name': displayName,
              'email': email,
              'uid': user.user!.uid,
              'verified': false,
            });
            await db.collection('users').doc('usernames').update({
              username: user.user!.uid,
            });
            Navigation.push(route: const SetupVerification());
          } else {
            error.value = locales.errorPasswordRequirements;
          }
        } else {
          error.value = locales.errorPasswordMismatch;
        }
      } else {
        error.value = locales.errorEmptyFields;
      }
    } on FirebaseAuthException catch (e) {
      final code = SignUpError.fromString(e.code);
      switch (code) {
        case SignUpError.emailAlreadyInUse:
          error.value = context.locale.errorEmailAlreadyInUse;
          break;
        case SignUpError.invalidEmail:
          error.value = context.locale.errorThisIsInvalid(context.locale.email);
          break;
        case SignUpError.operationNotAllowed:
          error.value = context.locale.errorOperationNotAllowed;
          break;
        case SignUpError.weakPassword:
          error.value = context.locale.errorWeakPassword;
          break;
        case SignUpError.unknownError:
          error.value = context.locale.errorUnknown;
          break;
      }
    }
  }

  /// Checks if the provided username is available and is compliant with
  /// the guidelines.
  void isUsernameCompliant({
    required String username,
    required ValueNotifier<String?> error,
    required BuildContext context,
    required String displayName,
    required String email,
    required FocusNode focusNode,
  }) async {
    error.value = null;
    final usernameReg = RegExp(r'^[a-zA-Z0-9_\.]+$');
    final usernamesDoc =
        await Database.firestore.collection('users').doc('usernames').get();
    final usernames = usernamesDoc.data() != null
        ? usernamesDoc.data()!
        : throw Exception('The database could not return the usernames data.');
    focusNode.unfocus();

    if (username != '') {
      if (usernameReg.hasMatch(username)) {
        if (!usernames.containsKey(username)) {
          Navigation.push(
            route: SetupPassword(
              displayName: displayName,
              username: username,
              email: email,
            ),
          );
        } else {
          error.value = context.locale.errorUsernameTaken;
          focusNode.requestFocus();
        }
      } else {
        error.value =
            context.locale.errorThisIsInvalid(context.locale.username);
        focusNode.requestFocus();
      }
    } else {
      error.value = context.locale.errorFieldEmpty;
      focusNode.requestFocus();
    }
  }

  Future changeName({
    required String name,
    required BuildContext context,
    required ValueNotifier<String> error,
  }) async {
    FocusScope.of(context).unfocus();
    try {
      final auth = FirebaseAuth.instance.currentUser;
      final db =
          Database.firestore.collection('users').doc(await user.getUsername());
      await db.update({
        'name': name,
      });
      await auth?.updateDisplayName(name);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future signOut(BuildContext context, WidgetRef ref) async {
    try {
      await FirebaseAuth.instance.signOut();
      ref.invalidate(Core.chats.chatListProvider.future);
      Navigation.pushPermanent(context: context, route: const Setup());
    } catch (e) {
      throw Exception('Something is wrong...');
    }
  }

  // TODO: Rebuild function but change username from the usernames document as well.
  @Deprecated('')
  Future changeUsername({
    required String username,
    required BuildContext context,
    required ValueNotifier error,
  }) async {
    FocusScope.of(context).unfocus();
    try {
      final db = Database.firestore.collection('users');
      final prefs = await SharedPreferences.getInstance();
      final data = await db.doc(await user.getUsername()).get().then(
            (value) => (value.data() != null
                ? value.data()!
                : throw Exception(
                    'The database returned a null username list.',
                  )) as Map<String, Object>,
          );
      await db.doc(await user.getUsername()).delete();
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
      for (final strings in splitedName) {
        if (strings.isNotEmpty) {
          arrayOfInitials.add(strings.substring(0, 1));
        }
      }
      initials = arrayOfInitials.join();
    }
    return initials;
  }

  /// Attention: This returns a gs:// link.
  /// This should only be used with [FirebaseImage].
  String? getProfilePicture(String? id, {bool isGroup = false}) {
    if (id != null) {
      if (isGroup) {
        return 'gs://allo-ms.appspot.com/chats/$id.png';
      } else {
        return 'gs://allo-ms.appspot.com/profilePictures/$id.png';
      }
    }
    return null;
  }

  Future sendPasswordResetEmail({
    required String email,
    required BuildContext context,
  }) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    Core.stub.showInfoBar(
      icon: Icons.mail_outline,
      text: context.locale.resetLinkSent,
    );
  }

  /// In case the user wants to change sensible information, you need to reauthenticate the user.
  /// This does just that.
  ///
  /// Pairs with [VerifyIdentity]
  Future reauthenticate(
    String password,
    ValueNotifier<String?> error,
    BuildContext context,
    Widget nextRoute,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    try {
      await user?.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email!, password: password),
      );
      Navigation.pushReplacement(nextRoute);
    } on FirebaseAuthException catch (e) {
      final code = ReauthenticationError.fromString(e.code);
      switch (code) {
        case ReauthenticationError.userMismatch:
          error.value = 'Credential mismatch. Contact administrator.';
          break;
        case ReauthenticationError.userNotFound:
          error.value = context.locale.errorUserNotFount;
          break;
        case ReauthenticationError.invalidCredential:
          error.value = 'Invalid Credential';
          break;
        case ReauthenticationError.invalidEmail:
          error.value = context.locale.errorThisIsInvalid(context.locale.email);
          break;
        case ReauthenticationError.wrongPassword:
          error.value = context.locale.errorWrongPassword;
          break;
        case ReauthenticationError.invalidVerificationCode:
          error.value = 'Invalid Verification Code';
          break;
        case ReauthenticationError.invalidVerificationId:
          error.value = 'Invalid Verification Id';
          break;
        case ReauthenticationError.tooManyRequests:
          error.value = context.locale.errorTooManyRequests;
          break;
        case ReauthenticationError.unknownError:
          error.value = context.locale.errorUnknown;
      }
    }
  }
}
