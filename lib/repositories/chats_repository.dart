import 'dart:convert';

import 'package:allo/repositories/auth_repository.dart';
import 'package:allo/repositories/repositories.dart';
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

class TextMessage {
  TextMessage(
      {required this.text,
      required this.chatId,
      required this.context,
      required this.chatName});
  final String text;
  final String chatId;
  final BuildContext context;
  final String chatName;
}

class ImageMessage {}

class MessageTypes {
  static final String TEXT = 'text';
  static final String IMAGE = 'image';
}

final chatsProvider = Provider<ChatsRepository>((ref) => ChatsRepository());

class ChatsRepository {
  final SendMessage send = SendMessage();

  Future deleteMessage(
      {required String messageId, required String chatId}) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}

class SendMessage {
  Future sendTextMessage(
      {required String text,
      required String chatId,
      required BuildContext context,
      required String chatName,
      TextEditingController? controller}) async {
    final db = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final auth = context.read(Repositories.auth);
    await db.collection('messages').add({
      'type': MessageTypes.TEXT,
      'name': auth.user.name,
      'username': await auth.user.username,
      'uid': auth.user.uid,
      'text': text,
      'time': DateTime.now(),
    });
    if (controller != null) {
      controller.clear();
    }
    await _sendNotification(
        chatName: chatName,
        name: auth.user.name,
        content: text,
        chatId: chatId);
  }

  Future sendImageMessage() async {}

  Future _sendNotification(
      {required String chatName,
      required String name,
      required String content,
      required String chatId}) async {
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
        }
      }),
    );
  }
}
