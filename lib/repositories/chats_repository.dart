import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MessageType {
  TEXT_ONLY,
  IMAGE_WITHOUT_DESCRIPTION,
  IMAGE_WITH_DESCRIPTION,
  CHAT_PILL,
  UNSUPPORTED,
}

final chatsProvider = Provider<ChatsRepository>((ref) => ChatsRepository());

class ChatsRepository {
  /// The sendMessage() function is experimental and its use is not recommended.
  /// Please use the writeMessage() function below to send legacy messages
  /// to the database.
  Future sendMessage(
      String universalTextCommunication,
      PickedFile? multimediaFile,
      MessageType messageType,
      String chatReference,
      TextEditingController inputMethodTextController) async {
    var db = FirebaseFirestore.instance;
    var auth = FirebaseAuth.instance;
    var prefs = await SharedPreferences.getInstance();
    var senderUsername = prefs.getString('username') ??
        await db.collection('users').doc('usernames').get().then((value) {
          String databaseUsername = value.data()?[auth.currentUser?.uid];
          prefs.setString('username', databaseUsername);
          return prefs.getString('username')!;
        });
    var senderName = prefs.getString('name') ??
        await db
            .collection('users')
            .doc(auth.currentUser?.uid)
            .get()
            .then((value) {
          String databaseUserAccountName = value.data()?['name'];
          prefs.setString('name', databaseUserAccountName);
          return prefs.getString('name')!;
        });
    try {
      if (messageType == MessageType.TEXT_ONLY) {
        inputMethodTextController.clear();
        await db
            .collection('chats')
            .doc(chatReference)
            .collection('messages')
            .add({
          'messageTextContent': universalTextCommunication,
          'senderUID': auth.currentUser?.uid,
          'senderName': senderName,
          'time': DateTime.now(),
        });
      } else if (messageType == MessageType.IMAGE_WITHOUT_DESCRIPTION) {
        // TODO: Handle image uploading and Firestore behaviour
      } else if (messageType == MessageType.IMAGE_WITH_DESCRIPTION) {
        // TODO: Handle image uploading and Firestore behaviour
      }
    } catch (e) {
      //TODO: Avoid empty catch blocks
    }
  }

  Future writeMessage(String messageTextContent, String chatReference,
      TextEditingController messageController) async {
    var db = FirebaseFirestore.instance;
    var auth = FirebaseAuth.instance;
    try {
      messageController.clear();
      var senderUsername =
          await db.collection('users').doc('usernames').get().then((value) {
        return value.data()?[auth.currentUser?.uid];
      });
      await db
          .collection('chats')
          .doc(chatReference)
          .collection('messages')
          .add({
        'messageTextContent': messageTextContent,
        'senderUsername': senderUsername,
        'time': DateTime.now(),
        'senderFirebaseUID': auth.currentUser?.uid,
      });
    } catch (e) {
      print(e);
    }
  }

  // Future sendPictureMessage() async {
  //   PickedFile selected = await ImagePicker()
  //       .getImage(source: ImageSource.camera)
  //       .then((value) //  TODO: Add image cropper
  //           )
  //       .then(
  //           (value) // TODO: Add image uploader and compose Firestore and Storage
  //           );
  // }
}
