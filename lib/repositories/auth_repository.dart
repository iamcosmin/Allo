import 'package:allo/interface/home/stack_navigator.dart';
import 'package:allo/interface/login/signup.dart';
import 'package:allo/interface/login/login.dart';
import 'package:allo/main.dart';
import 'package:allo/repositories/preferences_repository.dart';
// import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Spec:
// Use a error provider to provide error input to a function

final errorProvider =
    StateNotifierProvider<ErrorProvider, String>((ref) => ErrorProvider());

class ErrorProvider extends StateNotifier<String> {
  ErrorProvider() : super('');

  void passError(String error) {
    state = error;
  }
}

final authProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  AuthRepository(this.ref);
  final ProviderReference ref;

  Future returnUserDetails() async {
    return FirebaseAuth.instance.currentUser;
  }

  /// Checks if the user is eligible for login or signup.
  Future checkAuthenticationAbility(
      {required String email,
      required ValueNotifier<String> error,
      required BuildContext context}) async {
    try {
      FocusScope.of(context).unfocus();
      final List instance =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (instance.toString() == '[]') {
        await ref.read(Repositories.navigation).push(
            context, SetupName(email), SharedAxisTransitionType.horizontal);
      } else if (instance.toString() == '[password]') {
        await ref.read(Repositories.navigation).push(
            context,
            EnterPassword(
              email: email,
            ),
            SharedAxisTransitionType.horizontal);
      }
    } catch (e) {
      error.value = 'Acest email este invalid.';
    }
  }

  Future signIn(
      {required String email,
      required String password,
      required BuildContext context,
      required ValueNotifier<String> error}) async {
    try {
      FocusScope.of(context).unfocus();
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await context.read(Repositories.navigation).pushPermanent(
          context, StackNavigator(), SharedAxisTransitionType.scaled);
      await context.read(preferencesProvider).setBool('isAuth', true);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-disabled':
          error.value = ErrorCodes.userDisabled;
          break;
        case 'wrong-password':
          error.value = ErrorCodes.wrongPassword;
          break;
        default:
          error.value = 'O eroare s-a întâmplat.';
          break;
      }
    }
  }

  Future signUp(
      {required String email,
      required String password,
      required String displayName,
      required String username,
      required ValueNotifier<String> error,
      required BuildContext context}) async {
    try {
      final user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await context.read(preferencesProvider).setBool('isAuth', true);
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
      await ref
          .read(navigationProvider)
          .push(context, StackNavigator(), SharedAxisTransitionType.horizontal);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'operation-not-allowed':
          error.value = 'Momentan, înregistrările sunt închise.';
      }
    }
  }

  Future sendEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  Future configureUsername(String _username, BuildContext context) async {
    var usernames = await FirebaseFirestore.instance
        .collection('users')
        .doc('usernames')
        .get();
    if (usernames.data()![_username] != null) {
      return '$_username nu este disponibil!';
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('usernames')
          .update({
        FirebaseAuth.instance.currentUser!.uid: _username,
      });
      await Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => StackNavigator()),
          (route) => false);
      return '';
    }
  }

  Future signOut(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key != 'isDarkModeEnabled') {
          await prefs.remove(key);
        }
      }
      await FirebaseAuth.instance.signOut();
      await context
          .read(Repositories.navigation)
          .pushPermanent(context, MyApp(), SharedAxisTransitionType.scaled);
    } catch (e) {
      throw Exception('Something is wrong...');
    }
  }

  String? returnProfilePicture() {
    return FirebaseAuth.instance.currentUser?.photoURL;
  }

  String returnAuthenticatedNameInitials() {
    final auth = FirebaseAuth.instance.currentUser;
    var name = auth?.displayName ?? '';
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

  Future<String> getUserProfilePicture(String uid) async {
    return await FirebaseStorage.instance
        .ref()
        .child('profilePictures/$uid.png')
        .getDownloadURL();
  }

  String returnName() {
    return FirebaseAuth.instance.currentUser!.displayName!;
  }

  void cache(BuildContext context) async {
    final prefs = context.read(sharedPreferencesProvider);
    if (prefs.getString('displayName') == null) {
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      final userDataMap = userDocument.data() as Map;
      final name = userDataMap['name'];
      await prefs.setString('displayName', name);
    }
  }
}

class SignUp {}
