import 'dart:developer';

import 'package:allo/logic/backend/authentication/errors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../core.dart';
import 'authentication.dart';

class CurrentUser {
  CurrentUser();

  User get firebaseUser => FirebaseAuth.instance.currentUser!;

  ///* 1. User details:

  /// The current name of the authenticated user.
  /// Can be null if the user has no name.
  String? get name => firebaseUser.displayName;

  /// The current email of the authenticated user.
  String get email =>
      firebaseUser.email ??
      (throw Exception(
        'This client is compatible only with email-password based authentication. Please update the client or contact the administrator.',
      ));

  /// The current user id of the authenticated user.
  String get userId => firebaseUser.uid;

  /// Gets a link of the current profile picture of the account.
  /// Returns null if one does not exist.
  String? get profilePictureUrl => Core.auth.getProfilePicture(userId);

  /// Returns the initials of the name of the authenticated account.
  String get nameInitials {
    if (name != null) {
      return Core.auth.returnNameInitials(name!);
    } else {
      log('Returned an empty nameInitials.');
      return '';
    }
  }

  /// A [FutureProvider] with the username of the authenticated user.
  /// This ensures no suplimentary calls to the database are made, caching the username
  /// for the current session.
  final usernameProvider = FutureProvider<String>((ref) {
    return Core.auth.user.getUsername();
  });

  Future<void> updateEmail(
    String newEmail,
    ValueNotifier<String?> error,
    BuildContext context,
  ) async {
    try {
      await firebaseUser.updateEmail(newEmail);
      Navigation.backward();
    } on FirebaseException catch (e) {
      final code = UpdateEmailError.fromString(e.code);
      switch (code) {
        case UpdateEmailError.invalidEmail:
          error.value = context.locale.errorThisIsInvalid(context.locale.email);
          break;
        case UpdateEmailError.emailAlreadyInUse:
          error.value = context.locale.errorEmailAlreadyInUse;
          break;
        case UpdateEmailError.requiresRecentLogin:
          error.value = 'This operation requires identity verification';
          break;
        case UpdateEmailError.unknownError:
          error.value = context.locale.errorUnknown;
      }
    }
  }

  /// Gets the current username from the local or remote database, depending if
  /// it is cached or not.
  Future<String> getUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return await cache(
      key: 'username',
      fetch: () async {
        final db = Database.firestore;
        final usernames = await db.collection('users').doc('usernames').get();
        final usernamesMap = usernames.data();
        final username = usernamesMap?.keys
            .firstWhere((element) => usernamesMap[element] == uid);
        return username;
      },
      type: String,
    );
  }

  // Needs to be relocated
  Future<Stream<TaskSnapshot>> uploadImage(XFile file, String path) async {
    final storage = FirebaseStorage.instance;
    return storage
        .ref(path)
        .putData(
          await file.readAsBytes(),
          SettableMetadata(contentType: 'image/png'),
        )
        .snapshotEvents;
  }

  /// Updates the profile picture of the signed in account.
  Future updateProfilePicture({
    required ValueNotifier<double> percentage,
    required BuildContext context,
    Widget? route,
  }) async {
    void cancel() {
      Core.stub.showInfoBar(
        icon: Icons.cancel,
        text: context.locale.canceledOperation,
      );
    }

    XFile? finalImage;
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      if (kIsWeb) {
        finalImage = pickedImage;
      } else {
        // TODO (iamcosmin): Replace this with https://pub.dev/packages/cropperx
        final editedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          uiSettings: [
            AndroidUiSettings(
              activeControlsWidgetColor: context.colorScheme.primary,
              backgroundColor: context.colorScheme.surface,
              statusBarColor: context.colorScheme.surface,
              toolbarColor: context.colorScheme.surface,
              toolbarWidgetColor: context.colorScheme.onSurface,
              toolbarTitle: '${context.locale.edit} ${context.locale.image}',
              cropGridColor: context.colorScheme.onSurface,
              cropFrameColor: context.colorScheme.onSurface,
            ),
          ],
        );
        if (editedImage != null) {
          finalImage = XFile.fromData(await editedImage.readAsBytes());
        }
      }
      if (finalImage != null) {
        (await uploadImage(finalImage, 'profilePictures/$userId.png'))
            .listen((event) async {
          switch (event.state) {
            case TaskState.paused:
              // Return to the screen that the event is paused.
              if (kDebugMode) {
                print('Paused');
              }
              break;
            case TaskState.running:
              percentage.value = event.bytesTransferred / event.totalBytes;
              break;
            case TaskState.success:
              percentage.value = 1.0;
              await Future.delayed(const Duration(seconds: 1));
              percentage.value = 0.0;
              if (kDebugMode) {
                print(event.ref.fullPath);
              }
              await firebaseUser.updatePhotoURL(event.ref.fullPath);
              if (route != null) {
                Navigation.forward(route);
              } else {
                Navigation.backward();
              }
              break;
            case TaskState.canceled:
              // Handle canceling.
              if (kDebugMode) {
                print('Canceled!');
              }
              break;
            case TaskState.error:
              throw Exception(
                'An error has occured while updating the profile picture.',
              );
          }
        });
      } else {
        cancel();
      }
    }
    // if (uneditedImageFile != null) {
    //   if (kIsWeb) {
    //     imageFile = uneditedImageFile;
    //     loaded.value = true;
    //   } else {
    //     final editImageFile = await ImageCropper().cropImage(
    //       sourcePath: pickFromGallery!.path,
    //       aspectRatioPresets: [CropAspectRatioPreset.square],
    //     );
    //     final convertedEditImageFile = PickedFile(editImageFile!.path);
    //     imageFile = convertedEditImageFile;
    //     loaded.value = true;
    //   }
    //   final filePath = 'profilePictures/$userId.png';
    //   final uploadTask = FirebaseStorage.instance.ref(filePath).putData(
    //         await imageFile.readAsBytes(),
    //         SettableMetadata(contentType: 'image/png'),
    //       );
    //   uploadTask.snapshotEvents.listen(
    //     (snapshot) async {
    //       if (kDebugMode) {
    //         print(
    //           '${snapshot.bytesTransferred} / ${snapshot.totalBytes} = ${snapshot.bytesTransferred / snapshot.totalBytes}',
    //         );
    //       }
    //       if (snapshot.bytesTransferred / snapshot.totalBytes <= 1.0) {
    //         percentage.value = snapshot.bytesTransferred / snapshot.totalBytes;
    //       }
    //       if (snapshot.bytesTransferred / snapshot.totalBytes == 1.0) {
    //         await Future.delayed(const Duration(seconds: 1));
    //       }

    //       if (snapshot.state == TaskState.success) {
    //         await user!.updatePhotoURL(
    //           FirebaseStorage.instance.ref().child(filePath).fullPath,
    //         );
    //         if (route == null) {
    //           Navigation.pop();
    //         } else {
    //           Navigation.push(route: route);
    //         }
    //       }
    //     },
    //   );
    // } else {
    //   Core.stub.showInfoBar(
    //     icon: Icons.cancel,
    //     text: context.locale.canceledOperation,
    //   );
    // }
  }

  Future deleteProfilePicture({required BuildContext context}) async {
    final filePath = 'profilePictures/$userId.png';
    await FirebaseStorage.instance.ref().child(filePath).delete();
    await FirebaseAuth.instance.currentUser?.updatePhotoURL(null);
    Core.stub
        .showInfoBar(icon: Icons.info, text: 'Picture deleted successfully.');
  }
}
