import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class ProfilePictureSettings extends HookWidget {
  File? _imageFile;
  bool loaded = false;
  bool loading = false;
  UploadTask? _uploadTask;

  @override
  Widget build(BuildContext ctx) {
    var loaded = useState(false);
    var imageFile = useState(_imageFile);
    var loading = useState(false);
    var uploadTask = useState(_uploadTask);

    pickAndEditImage(context) async {
      var pickFromGallery =
          await ImagePicker().getImage(source: ImageSource.gallery);
      var uneditedImageFile = File(pickFromGallery!.path);
      if (!kIsWeb) {
        var editImageFile = await ImageCropper.cropImage(
            sourcePath: pickFromGallery.path,
            aspectRatioPresets: [CropAspectRatioPreset.square]);
        imageFile.value = editImageFile!;
        loaded.value = true;
      } else {
        imageFile.value = uneditedImageFile;
        loaded.value = true;
      }
      var user = FirebaseAuth.instance.currentUser!;
      loading.value = true;
      final storage = FirebaseStorage.instance;
      var filePath = 'profilePictures/${user.email}.png';
      uploadTask.value =
          storage.ref().child(filePath).putFile(imageFile.value!);
      await uploadTask.value!.whenComplete(() async {
        await user.updateProfile(
            photoURL: await uploadTask.value!.storage
                .ref()
                .child(filePath)
                .getDownloadURL());
        Navigator.pop(context);
      });
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Fotografie de profil'),
        previousPageTitle: 'Setări',
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoFormSection.insetGrouped(
              children: [
                CupertinoFormRow(
                  child: Container(),
                )
              ],
            ),
            Stack(
              children: [
                if (loaded.value == false) ...[
                  CupertinoButton(
                    onPressed: () => pickAndEditImage(ctx),
                    child: Text('Incarca imagine'),
                  )
                ] else ...[
                  StreamBuilder<TaskSnapshot>(
                    stream: uploadTask.value!.snapshotEvents,
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.state == TaskState.success) {
                          return Text('Succes!');
                        } else if (snapshot.data!.state == TaskState.error) {
                          return Text('Eroare');
                        } else if (snapshot.data!.state == TaskState.running) {
                          return SizedBox(
                            width: 100,
                            height: 100,
                            child: Column(
                              children: [
                                Text(((snapshot.data!.bytesTransferred *
                                        100 /
                                        snapshot.data!.totalBytes))
                                    .toString()),
                                ProgressRing(
                                  value: ((snapshot.data!.bytesTransferred *
                                      100 /
                                      snapshot.data!.totalBytes)),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text('?');
                        }
                      } else {
                        return ProgressRing();
                      }
                    },
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
