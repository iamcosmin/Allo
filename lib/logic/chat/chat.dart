import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:allo/logic/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class MessageTypes {
  // ignore: constant_identifier_names
  static const String TEXT = 'text';
  // ignore: constant_identifier_names
  static const String IMAGE = 'image';
}

class Chat {
  Chat({required this.chatId});
  final String chatId;

  Messages get messages => Messages(chatId: chatId);
}

class Messages {
  Messages({required this.chatId});
  final String chatId;

  Future deleteMessage({required String messageId}) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future markAsRead({required String messageId}) async {
    // This will mark the message as read.
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'read': true,
    });
  }

  Future sendTextMessage(
      {required String text,
      required BuildContext context,
      required String chatName,
      TextEditingController? controller,
      required String chatType}) async {
    if (controller != null) {
      controller.clear();
    }
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .update({'typing': false});
    final db = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final auth = Core.auth;
    await db.collection('messages').add({
      'type': MessageTypes.TEXT,
      'name': auth.user.name,
      'username': await auth.user.username,
      'uid': auth.user.uid,
      'text': text,
      'time': Timestamp.now(),
    });
    await _sendNotification(
        chatName: chatName,
        name: auth.user.name,
        content: text,
        uid: auth.user.uid,
        chatType: chatType);
  }

  Future sendImageMessage(
      {required String chatName,
      required XFile imageFile,
      String? description,
      required ValueNotifier<double> progress,
      required BuildContext context,
      required String chatType}) async {
    final auth = Core.auth;
    final path = 'chats/$chatId/${DateTime.now()}_${await auth.user.username}';
    final storage = FirebaseStorage.instance;
    final db = FirebaseFirestore.instance.collection('chats').doc(chatId);

    final task = storage.ref(path).putData(await imageFile.readAsBytes(),
        SettableMetadata(contentType: 'image/png'));
    task.snapshotEvents.listen((event) async {
      progress.value = event.bytesTransferred / event.totalBytes;
      if (event.state == TaskState.success) {
        progress.value = 1.1;
        await db.collection('messages').add({
          'type': MessageTypes.IMAGE,
          'name': auth.user.name,
          'username': await auth.user.username,
          'uid': auth.user.uid,
          'link': await event.ref.getDownloadURL(),
          'description': description,
          'time': DateTime.now(),
        });
        await _sendNotification(
            chatName: chatName,
            name: auth.user.name,
            content: 'Imagine' + (description != null ? ' - $description' : ''),
            uid: auth.user.uid,
            chatType: chatType);
        Navigator.of(context).pop();
      }
    });
  }

  Future _sendNotification(
      {required String chatName,
      required String name,
      required String content,
      required String uid,
      required String chatType}) async {
    await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Authorization':
            'key=AAAA9EHEBh8:APA91bEwgamP8cWZQewq7qkVrydw6BduUEhgeufHV9SZ2pBoRYcJy7GynZ-XZWVzuzDrERK7ZDJlwZiPWZJ4oWaKh9rwjlL8GMnLD0znMKZ6CZw6BPRtjU1xBtGUv-Nds0wydptQcuz6',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'to': '/topics/$chatId',
        'data': {
          'chatName': chatName,
          'senderName': name,
          'text': content,
          'toChat': chatId,
          'uid': uid,
          'type': chatType
        }
      }),
    );
  }
}
