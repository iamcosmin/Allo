import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

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
    var senderName = FirebaseAuth.instance.currentUser!.displayName!;
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
        await post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Authorization':
                'key=AAAA9EHEBh8:APA91bEwgamP8cWZQewq7qkVrydw6BduUEhgeufHV9SZ2pBoRYcJy7GynZ-XZWVzuzDrERK7ZDJlwZiPWZJ4oWaKh9rwjlL8GMnLD0znMKZ6CZw6BPRtjU1xBtGUv-Nds0wydptQcuz6',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            'to': '/topics/$chatReference',
            'notification': {
              'title': 'Mesaj de la $senderName',
              'body': '$universalTextCommunication'
            }
          }),
        );
      } else if (messageType == MessageType.IMAGE_WITHOUT_DESCRIPTION) {
        // TO DO: Handle image uploading and Firestore behaviour
      } else if (messageType == MessageType.IMAGE_WITH_DESCRIPTION) {
        // TO DO: Handle image uploading and Firestore behaviour
      }
    } catch (e) {
      //TO DO: Avoid empty catch blocks
    }
  }

  Future deleteMessage(
      {required String messageId, required String chatId}) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
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
  //       .then((value) //  TO DO: Add image cropper
  //           )
  //       .then(
  //           (value) // TO DO: Add image uploader and compose Firestore and Storage
  //           );
  // }
}
