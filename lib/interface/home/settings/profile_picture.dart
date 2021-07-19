import 'package:allo/components/person_picture.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class ProfilePictureSettings extends HookWidget {
  bool loaded = false;
  bool loading = false;

  @override
  Widget build(BuildContext ctx) {
    var loaded = useState(false);
    var percetange = useState(0.0);
    final auth = useProvider(Repositories.auth);

    void pickAndEditImage(context) async {
      XFile imageFile;
      var pickFromGallery =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      var uneditedImageFile = XFile(pickFromGallery!.path);
      if (kIsWeb) {
        imageFile = uneditedImageFile;
        loaded.value = true;
      } else {
        var editImageFile = await ImageCropper.cropImage(
            sourcePath: pickFromGallery.path,
            aspectRatioPresets: [CropAspectRatioPreset.square]);
        var convertedEditImageFile = XFile(editImageFile!.path);
        imageFile = convertedEditImageFile;
        loaded.value = true;
      }
      var user = FirebaseAuth.instance.currentUser;
      var filePath = 'profilePictures/${user?.uid}.png';
      var uploadTask = FirebaseStorage.instance.ref(filePath).putData(
          await imageFile.readAsBytes(),
          SettableMetadata(contentType: 'image/png'));
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) async {
        percetange.value =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        if (snapshot.state == TaskState.success) {
          await user!.updatePhotoURL(await FirebaseStorage.instance
              .ref()
              .child(filePath)
              .getDownloadURL());
          Navigator.pop(context);
        }
      });
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Fotografie de profil'),
        previousPageTitle: 'Setări',
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 30)),
            CupertinoFormSection.insetGrouped(
              children: [
                CupertinoFormRow(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 110,
                          width: 110,
                          child: ProgressRing(
                            value: percetange.value,
                          ),
                        ),
                        PersonPicture.determine(
                            radius: 100,
                            profilePicture: auth.returnProfilePicture(),
                            initials: auth.returnAuthenticatedNameInitials()),
                      ],
                    ),
                  ),
                )
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: Text('Gestionează imaginea de profil'),
              children: [
                GestureDetector(
                  onTap: () => pickAndEditImage(ctx),
                  child: CupertinoFormRow(
                    prefix: Text('Încarcă imagine'),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, right: 5),
                      child: Icon(
                        CupertinoIcons.right_chevron,
                        color: CupertinoColors.systemGrey,
                        size: 15,
                      ),
                    ),
                  ),
                ),
                CupertinoFormRow(
                  prefix: Text('Șterge imaginea'),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, right: 5),
                    child: Icon(CupertinoIcons.right_chevron,
                        color: CupertinoColors.systemGrey, size: 15),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
