import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class ProfilePictureSettings extends HookWidget {
  File? imageFile;
  bool? loaded;
  bool loading = false;

  @override
  Widget build(BuildContext ctx) {
    Future<void> _pickImage() async {
      var selected = await ImagePicker().getImage(source: ImageSource.gallery);
      imageFile = File(selected!.path);
      useEffect(() {
        imageFile = imageFile;
        loaded = true;
      }, const []);
    }

    Future uploadTask() async {
      var user = FirebaseAuth.instance.currentUser!;
      useEffect(() {
        loading = true;
      }, const []);
      final FirebaseStorage _storage =
          FirebaseStorage(storageBucket: 'gs://vanto-47ee5.appspot.com');
      StorageUploadTask _upload;
      String filePath = 'profile/${user.email}.png';
      _upload = _storage.ref().child(filePath).putFile(_imageFile);
      UserUpdateInfo updateInfo = UserUpdateInfo();
      String url = await _storage.ref().child(filePath).getDownloadURL();
      updateInfo.photoUrl = url;
      await user.updateProfile(updateInfo);
      await user.reload();
      Navigator.pushReplacement(
          context, CupertinoPageRoute(builder: (context) => TabNavigator()));
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Fotografie de profil'),
        previousPageTitle: 'Setări',
      ),
      child: Container(),
    );
  }
}
