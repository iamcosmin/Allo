import 'package:allo/interface/home/stack_navigator.dart';
import 'package:allo/interface/login/existing/enter_password.dart';
import 'package:allo/interface/login/new/setup_name.dart';
import 'package:allo/interface/login/new/setup_password.dart';
import 'package:allo/interface/login/new/setup_verification.dart';
import 'package:allo/main.dart';
// import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

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
Future _cache(
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

class AuthRepository {
  final CurrentUser user = CurrentUser();

  Future<User?> returnUserDetails() async {
    return FirebaseAuth.instance.currentUser;
  }

  /// Checks if the user is eligible for login or signup.
  Future checkAuthenticationAbility(
      {required String email,
      required ValueNotifier<String> error,
      required BuildContext context}) async {
    try {
      FocusScope.of(context).unfocus();
      error.value = '';
      final List instance =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (instance.toString() == '[]') {
        await context.read(Repositories.navigation).push(
              context,
              SetupName(email),
            );
      } else if (instance.toString() == '[password]') {
        await context.read(Repositories.navigation).push(
              context,
              EnterPassword(
                email: email,
              ),
            );
      }
    } catch (e) {
      error.value = 'Acest email este invalid.';
    }
  }

  //? [Login]
  /// Signs in an Allo user by email and password.
  Future signIn(
      {required String email,
      required String password,
      required BuildContext context,
      required ValueNotifier<String> error}) async {
    try {
      FocusScope.of(context).unfocus();
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => StackNavigator(),
          ),
          (route) => false);
      var prefs = await SharedPreferences.getInstance();
      await prefs.setBool('authenticated', true);
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

  //? Signup
  /// Signs up the user by email and password.
  Future signUp(
      {required String email,
      required String password,
      required String confirmPassword,
      required String displayName,
      required String username,
      required ValueNotifier<String> error,
      required BuildContext context}) async {
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
            var prefs = await SharedPreferences.getInstance();
            await prefs.setBool('authenticated', true);
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
            await context.read(navigationProvider).push(
                  context,
                  const SetupVerification(),
                );
          } else {
            error.value = 'Parola ta nu respectă cerințele.';
          }
        } else {
          error.value = 'Parolele nu sunt la fel.';
        }
      } else {
        error.value = 'Parolele nu trebuie să fie goale.';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'operation-not-allowed':
          error.value = 'Momentan, înregistrările sunt închise.';
      }
    }
  }

  /// Checks if the provided username is available and is compliant with
  /// the guidelines.
  Future isUsernameCompliant(
      {required String username,
      required ValueNotifier<String> error,
      required BuildContext context,
      required String displayName,
      required String email}) async {
    final usernameReg = RegExp(r'^[a-zA-Z0-9_\.]+$');
    final navigation = context.read(Repositories.navigation);
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
            context,
            SetupPassword(
              displayName: displayName,
              username: username,
              email: email,
            ),
          );
        } else {
          error.value = 'Acest nume de utilizator este deja luat.';
        }
      } else {
        error.value = 'Numele de utilizator nu este valid.';
      }
    } else {
      error.value = 'Numele de utilizator nu poate fi gol.';
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

  Future<String> getUserProfilePicture(String uid) async {
    return await FirebaseStorage.instance
        .ref()
        .child('profilePictures/$uid.png')
        .getDownloadURL();
  }
}

class CurrentUser {
  /// The username of the authenticated account.
  Future<String> get username async {
    return await _cache(
      key: 'username',
      fetch: () async {
        final db = FirebaseFirestore.instance;
        final usernames = await db.collection('users').doc('usernames').get();
        final usernamesMap = usernames.data();
        final username = usernamesMap?.keys
            .firstWhere((element) => usernamesMap[element] == uid);
        return username;
      },
      type: String,
    );
  }

  /// Gets a link of the current profile picture of the account. Returns
  /// null if one does not exist.
  String? get profilePicture {
    return FirebaseAuth.instance.currentUser?.photoURL;
  }

  /// Returns the name of the authenticated account.
  String get name {
    return FirebaseAuth.instance.currentUser!.displayName!;
  }

  /// Returns the initials of the name of the authenticated account.
  String get nameInitials {
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

  String get uid {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  /// Updates the profile picture of the signed in account.
  Future updateProfilePicture(
      {required ValueNotifier<bool> loaded,
      required ValueNotifier<double> percentage,
      required BuildContext context,
      Widget? route}) async {
    PickedFile imageFile;
    var pickFromGallery =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    var uneditedImageFile = PickedFile(pickFromGallery!.path);
    if (kIsWeb) {
      imageFile = uneditedImageFile;
      loaded.value = true;
    } else {
      var editImageFile = await ImageCropper.cropImage(
          sourcePath: pickFromGallery.path,
          aspectRatioPresets: [CropAspectRatioPreset.square]);
      var convertedEditImageFile = PickedFile(editImageFile!.path);
      imageFile = convertedEditImageFile;
      loaded.value = true;
    }
    var user = FirebaseAuth.instance.currentUser;
    var filePath = 'profilePictures/${user?.uid}.png';
    var uploadTask = FirebaseStorage.instance.ref(filePath).putData(
        await imageFile.readAsBytes(),
        SettableMetadata(contentType: 'image/png'));
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) async {
      percentage.value =
          (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
      if (snapshot.state == TaskState.success) {
        await user!.updatePhotoURL(await FirebaseStorage.instance
            .ref()
            .child(filePath)
            .getDownloadURL());
        if (route == null) {
          Navigator.pop(context);
        } else {
          await context.read(navigationProvider).push(
                context,
                route,
              );
        }
      }
    });
  }
}
