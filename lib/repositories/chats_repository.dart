import 'dart:convert';

import 'package:allo/repositories/repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

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

  Future markAsRead({required String chatId, required String messageId}) async {
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
}

class SendMessage {
  Future sendTextMessage(
      {required String text,
      required String chatId,
      required BuildContext context,
      required String chatName,
      TextEditingController? controller,
      required String chatType}) async {
    if (controller != null) {
      controller.clear();
    }
    final db = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final auth = context.read(Repositories.auth);
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
        chatId: chatId,
        uid: auth.user.uid,
        chatType: chatType);
  }

  Future sendImageMessage(
      {required String chatName,
      required String name,
      required XFile imageFile,
      String? description,
      required String chatId,
      required ValueNotifier<double> progress,
      required BuildContext context,
      required String chatType}) async {
    final auth = context.read(Repositories.auth);
    final path = 'chats/$chatId/${DateTime.now()}_${await auth.user.username}';
    final storage = FirebaseStorage.instance;
    final db = FirebaseFirestore.instance.collection('chats').doc(chatId);

    final task = storage.ref(path).putData(await imageFile.readAsBytes(),
        SettableMetadata(contentType: 'image/png'));
    task.snapshotEvents.listen((event) async {
      progress.value = (event.bytesTransferred / event.totalBytes) * 100;
      if (event.state == TaskState.success) {
        progress.value = 101;
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
            name: name,
            content: 'Imagine' + (description != null ? ' - $description' : ''),
            chatId: chatId,
            uid: auth.user.uid,
            chatType: chatType);
      }
    });
  }

  Future _sendNotification(
      {required String chatName,
      required String name,
      required String content,
      required String chatId,
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

class ChatType {
  static const String private = 'private';
  static const String group = 'group';
}

final loadChats = StateNotifierProvider<LoadChats, List>((ref) => LoadChats());

class LoadChats extends StateNotifier<List> {
  LoadChats() : super([]);
  Future getChatsData(BuildContext context) async {
    var chatIdList = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(await context.read(authProvider).user.username)
        .get()
        .then((DocumentSnapshot snapshot) {
      var map = snapshot.data() as Map;
      if (map.containsKey('chats')) {
        chatIdList = map['chats'] as List;
      }
    });

    var listOfMapChatInfo = <Map>[];
    if (chatIdList.isNotEmpty) {
      for (var chat in chatIdList) {
        var chatSnapshot = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chat)
            .get();
        var chatInfoMap = chatSnapshot.data() as Map;
        var name, profilepic, chatid;
        // Check if it is group or private
        if (chatInfoMap['type'] == ChatType.private) {
          chatid = chatSnapshot.id;
          for (Map member in chatInfoMap['members']) {
            if (member['uid'] != context.read(Repositories.auth).user.uid) {
              name = member['name'];
              profilepic = member['profilepicture'];
            }
          }
          listOfMapChatInfo.add({
            'type': ChatType.private,
            'name': name,
            'profilepic': profilepic,
            'chatId': chatid
          });
        } else if (chatInfoMap['type'] == ChatType.group) {
          if (chatInfoMap.containsKey('title')) {
            var chatInfo = {
              'type': ChatType.group,
              'name': chatInfoMap['title'],
              'chatId': chatSnapshot.id,
            };
            listOfMapChatInfo.add(chatInfo);
          }
        }
      }
    }
    state = listOfMapChatInfo;
  }
}
