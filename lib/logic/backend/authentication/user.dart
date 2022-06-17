import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../generated/l10n.dart';
import '../../core.dart';
import 'authentication.dart';

class CurrentUser {
  /// The username of the authenticated account.
  Future<String> get username async {
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

  /// Gets a link of the current profile picture of the account. Returns
  /// null if one does not exist.
  String? get profilePicture {
    return FirebaseAuth.instance.currentUser?.photoURL;
  }

  /// Returns the name of the authenticated account.
  String get name {
    return FirebaseAuth.instance.currentUser!.displayName!;
  }

  String get email {
    return FirebaseAuth.instance.currentUser!.email!;
  }

  /// Returns the initials of the name of the authenticated account.
  String get nameInitials {
    final auth = FirebaseAuth.instance.currentUser;
    final name = auth?.displayName ?? '';
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

  String get uid {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  /// Updates the profile picture of the signed in account.
  Future updateProfilePicture({
    required ValueNotifier<bool> loaded,
    required ValueNotifier<double> percentage,
    required BuildContext context,
    Widget? route,
  }) async {
    PickedFile imageFile;
    final locales = S.of(context);
    final pickFromGallery =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    final uneditedImageFile = pickFromGallery?.path != null
        ? PickedFile(pickFromGallery!.path)
        : null;
    if (uneditedImageFile != null) {
      if (kIsWeb) {
        imageFile = uneditedImageFile;
        loaded.value = true;
      } else {
        final editImageFile = await ImageCropper().cropImage(
          sourcePath: pickFromGallery!.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        );
        final convertedEditImageFile = PickedFile(editImageFile!.path);
        imageFile = convertedEditImageFile;
        loaded.value = true;
      }
      final user = FirebaseAuth.instance.currentUser;
      final filePath = 'profilePictures/${user?.uid}.png';
      final uploadTask = FirebaseStorage.instance.ref(filePath).putData(
            await imageFile.readAsBytes(),
            SettableMetadata(contentType: 'image/png'),
          );
      uploadTask.snapshotEvents.listen(
        (snapshot) async {
          if (kDebugMode) {
            print(
              '${snapshot.bytesTransferred} / ${snapshot.totalBytes} = ${snapshot.bytesTransferred / snapshot.totalBytes}',
            );
          }
          if (snapshot.bytesTransferred / snapshot.totalBytes <= 1.0) {
            percentage.value = snapshot.bytesTransferred / snapshot.totalBytes;
          }
          if (snapshot.bytesTransferred / snapshot.totalBytes == 1.0) {
            await Future.delayed(const Duration(seconds: 1));
          }

          if (snapshot.state == TaskState.success) {
            await user!.updatePhotoURL(
              await FirebaseStorage.instance
                  .ref()
                  .child(filePath)
                  .getDownloadURL(),
            );
            if (route == null) {
              Navigator.pop(context);
            } else {
              Core.navigation.push(route: route);
            }
          }
        },
      );
    } else {
      Core.stub
          .showInfoBar(icon: Icons.cancel, text: locales.canceledOperation);
    }
  }

  Future deleteProfilePicture({required BuildContext context}) async {
    final user = FirebaseAuth.instance.currentUser;
    final filePath = 'profilePictures/${user?.uid}.png';
    await FirebaseAuth.instance.currentUser?.updatePhotoURL(null);
    await FirebaseStorage.instance.ref().child(filePath).delete();
    Core.stub
        .showInfoBar(icon: Icons.info, text: 'Picture deleted successfully.');
  }
}
