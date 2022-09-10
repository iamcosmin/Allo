import 'dart:convert';

import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import '../../../components/chats/message_input.dart';

class Messages {
  Messages({required this.chatId});
  final String chatId;

  Future deleteMessage({required String messageId}) async {
    await Database.firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> markAsRead({required String messageId}) async {
    // This will mark the message as read.
    await Database.firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'read': true,
    });
  }

  Future<void> sendTextMessage({
    required String text,
    required String chatName,
    required ChatType chatType,
    TextEditingController? controller,
    ValueNotifier<InputModifier?>? modifier,
  }) async {
    if (controller != null) {
      controller.clear();
    }
    // Database.storage
    //     .collection('chats')
    //     .doc(chatId)
    //     .update({'typing': false});
    final db = Database.firestore.collection('chats').doc(chatId);
    final auth = Core.auth;
    if (modifier?.value == null) {
      await db.collection('messages').add({
        'type': MessageType.text.name,
        'name': auth.user.name,
        'username': await auth.user.getUsername(),
        'uid': auth.user.userId,
        'text': text,
        'time': Timestamp.now(),
      });
    } else if (modifier!.value! is ReplyInputModifier) {
      final replyMessageId = modifier.value?.id;
      modifier.value = null;
      await db.collection('messages').add({
        'type': MessageType.text.name,
        'name': auth.user.name,
        'username': await auth.user.getUsername(),
        'uid': auth.user.userId,
        'reply_to_message': replyMessageId,
        'text': text,
        'time': Timestamp.now(),
      });
    }
    await _sendNotification(
      profilePicture: Core.auth.user.profilePictureUrl,
      chatName: chatName,
      name: auth.user.name ?? (throw Exception('No name.')),
      content: text,
      uid: auth.user.userId,
      chatType: chatType,
    );
  }

  Future sendImageMessage({
    required String chatName,
    required XFile imageFile,
    required ValueNotifier<double> progress,
    required BuildContext context,
    required ChatType chatType,
    String? description,
  }) async {
    final auth = Core.auth;
    final path =
        'chats/$chatId/${DateTime.now()}_${auth.user.usernameProvider}';
    final storage = FirebaseStorage.instance;
    final db = Database.firestore.collection('chats').doc(chatId);

    final task = storage.ref(path).putData(
          await imageFile.readAsBytes(),
          SettableMetadata(contentType: 'image/png'),
        );
    task.snapshotEvents.listen((event) async {
      progress.value = event.bytesTransferred / event.totalBytes;
      if (event.state == TaskState.success) {
        progress.value = 1.0;
        await Future.delayed(const Duration(seconds: 1));
        progress.value = 0.0;
        final link = await event.ref.getDownloadURL();
        await db.collection('messages').add({
          'type': MessageType.image.name,
          'name': auth.user.name,
          'username': await auth.user.getUsername(),
          'uid': auth.user.userId,
          'link': link,
          'description': description,
          'time': DateTime.now(),
        });
        await _sendNotification(
          chatName: chatName,
          name: auth.user.name ?? (throw Exception('No name.')),
          content: 'Imagine ${description != null ? ' - $description' : ''}',
          uid: auth.user.userId,
          chatType: chatType,
          profilePicture: Core.auth.user.profilePictureUrl,
          photo: link,
        );
      }
    });
  }

  Future _sendNotification({
    required String chatName,
    required String name,
    required String content,
    required String uid,
    required ChatType chatType,
    required String? profilePicture,
    String? photo,
  }) async {
    await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Authorization':
            'key=AAAA9EHEBh8:APA91bEuh4aaXDlyaGFbtmnpm5fzHnKGRgYTXUkBTzZj3TFvWFIEVanDN3KrrpKQobOd4W690lv8C_7xcQ3XNkUelMMMeXuiNECqzcJx71BxFq3Y7Wo53tYVwwMpL1csVAPr5PXtBTRA',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'to': '/topics/$chatId',
        'priority': 'high',
        'data': {
          'type': 'message',
          'version': 1,
          'message': {
            'chat': {
              'name': chatName,
              'id': chatId,
              'type': chatType.name,
              'photoURL': null,
            },
            'sender': {'name': name, 'id': uid, 'photoURL': profilePicture},
            'content': {
              'type': 'text',
              'text': content,
            }
          },
        },
      }),
    );
  }
}
