import 'dart:convert';

import 'package:allo/components/chats/message_input.dart';
import 'package:allo/logic/chat/messages.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:allo/logic/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../types.dart';

class Chat {
  Chat({required this.chatId});
  final String chatId;

  Messages get messages => Messages(chatId: chatId);

  Future<List<Map<String, String?>>> getChatsList(BuildContext context) async {
    final _uid = Core.auth.user.uid;
    final _documents = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: _uid)
        .get();
    var _chatsMap = <Map<String, String?>>[];

    if (_documents.docs.isNotEmpty) {
      for (var chat in _documents.docs) {
        var chatInfo = chat.data();
        String? name, profilepic;
        // Check the chat type to sort accordingly
        switch (chatInfo['type']) {
          case ChatType.private:
            {
              for (var member in chatInfo['members']) {
                if (member['uid'] != Core.auth.user.uid) {
                  name = member['name'];
                  profilepic =
                      await Core.auth.getUserProfilePicture(member['uid']);
                }
              }
              _chatsMap.add({
                'type': ChatType.private,
                'name': name ?? '???',
                'profilepic': profilepic,
                'chatId': chat.id,
              });
              break;
            }
          case ChatType.group:
            {
              name = chatInfo['title'];
              profilepic = chatInfo['profilepic'];
              _chatsMap.add({
                'type': ChatType.group,
                'name': name ?? '???',
                'chatId': chat.id,
                'profilepic': profilepic,
              });
            }
        }
      }
    }
    return _chatsMap;
  }

  void streamChatMessages({
    required ValueNotifier<List<Message>> messages,
    required GlobalKey<AnimatedListState> listKey,
    int? limit,
  }) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(limit ?? 20)
        .snapshots()
        .listen(
      (event) async {
        for (var docChanges in event.docChanges) {
          switch (docChanges.type) {
            case DocumentChangeType.added:
              if (event.docChanges.length == 20) {
                listKey.currentState?.insertItem(docChanges.newIndex,
                    duration: const Duration(seconds: 0));
              } else {
                listKey.currentState?.insertItem(docChanges.newIndex,
                    duration: const Duration(milliseconds: 275));
              }
              final data = docChanges.doc.data() as Map<String, dynamic>;
              Message? message;
              switch (data['type']) {
                case MessageTypes.text:
                  {
                    if (data['reply_to_message'] != null) {
                      final replyQuery = await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(data['reply_to_message'])
                          .get();
                      final replyData = replyQuery.data();
                      message = TextMessage(
                        name: data['name'],
                        userId: data['uid'],
                        username: data['username'],
                        id: docChanges.doc.id,
                        timestamp: data['time'],
                        read: data['read'] ?? false,
                        text: data['text'],
                        data: data,
                        reply: replyData == null
                            ? null
                            : ReplyToMessage(
                                name: replyData['name'],
                                description: replyData['text'],
                              ),
                      );
                    } else {
                      message = TextMessage(
                        name: data['name'],
                        userId: data['uid'],
                        username: data['username'],
                        id: docChanges.doc.id,
                        timestamp: data['time'],
                        read: data['read'] ?? false,
                        text: data['text'],
                        data: data,
                      );
                    }
                    break;
                  }
                case MessageTypes.image:
                  {
                    if (data['reply_to_message'] != null) {
                      final replyQuery = await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(data['reply_to_message'])
                          .get();
                      final replyData = replyQuery.data();
                      message = ImageMessage(
                        name: data['name'],
                        userId: data['uid'],
                        username: data['username'],
                        id: docChanges.doc.id,
                        timestamp: data['time'],
                        read: data['read'] ?? false,
                        link: data['link'],
                        data: data,
                        reply: replyData == null
                            ? null
                            : ReplyToMessage(
                                name: replyData['name'],
                                description: replyData['description'],
                              ),
                      );
                    } else {
                      message = ImageMessage(
                        name: data['name'],
                        userId: data['uid'],
                        username: data['username'],
                        id: docChanges.doc.id,
                        timestamp: data['time'],
                        read: data['read'] ?? false,
                        link: data['link'],
                        data: data,
                      );
                    }
                    break;
                  }
              }
              message != null
                  ? messages.value.insert(docChanges.newIndex, message)
                  : null;
              break;
            case DocumentChangeType.modified:
              final data = docChanges.doc.data() as Map<String, dynamic>;
              Message? message;
              switch (data['type']) {
                case MessageTypes.text:
                  {
                    if (data['reply_to_message'] != null) {
                      final replyQuery = await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(data['reply_to_message'])
                          .get();
                      final replyData = replyQuery.data();
                      message = TextMessage(
                        name: data['name'],
                        userId: data['uid'],
                        username: data['username'],
                        id: docChanges.doc.id,
                        timestamp: data['time'],
                        read: data['read'],
                        text: data['text'],
                        data: data,
                        reply: replyData == null
                            ? null
                            : ReplyToMessage(
                                name: replyData['name'],
                                description: replyData['text'],
                              ),
                      );
                    } else {
                      message = TextMessage(
                          name: data['name'],
                          userId: data['uid'],
                          username: data['username'],
                          id: docChanges.doc.id,
                          timestamp: data['time'],
                          read: data['read'],
                          text: data['text'],
                          data: data);
                    }
                    break;
                  }
                case MessageTypes.image:
                  {
                    if (data['reply_to_message'] != null) {
                      final replyQuery = await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(data['reply_to_message'])
                          .get();
                      final replyData = replyQuery.data();
                      message = ImageMessage(
                        name: data['name'],
                        userId: data['uid'],
                        username: data['username'],
                        id: docChanges.doc.id,
                        timestamp: data['time'],
                        read: data['read'],
                        link: data['link'],
                        data: data,
                        reply: replyData == null
                            ? null
                            : ReplyToMessage(
                                name: replyData['name'],
                                description: replyData['description'],
                              ),
                      );
                    } else {
                      message = ImageMessage(
                          name: data['name'],
                          userId: data['uid'],
                          username: data['username'],
                          id: docChanges.doc.id,
                          timestamp: data['time'],
                          read: data['read'],
                          link: data['link'],
                          data: data);
                    }
                    break;
                  }
              }
              listKey.currentState?.setState(() {
                message != null
                    ? messages.value[docChanges.newIndex] = message
                    : null;
              });
              break;
            case DocumentChangeType.removed:
              listKey.currentState?.removeItem(
                docChanges.oldIndex,
                (context, animation) => SizeTransition(
                  axisAlignment: -1.0,
                  sizeFactor: animation,
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                        curve: Curves.easeIn, parent: animation),
                  ),
                ),
              );
              messages.value.removeAt(docChanges.oldIndex);
              break;
          }
        }
      },
    );
  }
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
      ValueNotifier<InputModifier?>? modifier,
      required String chatType}) async {
    if (controller != null) {
      controller.clear();
    }
    // FirebaseFirestore.instance
    //     .collection('chats')
    //     .doc(chatId)
    //     .update({'typing': false});
    final db = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final auth = Core.auth;
    final replyMessageId = modifier?.value?.action.replyMessageId;
    if (modifier?.value == null) {
      await db.collection('messages').add({
        'type': MessageTypes.text,
        'name': auth.user.name,
        'username': await auth.user.username,
        'uid': auth.user.uid,
        'text': text,
        'time': Timestamp.now(),
      });
    } else if (modifier?.value?.action.type == ModifierType.reply) {
      modifier?.value = null;
      await db.collection('messages').add({
        'type': MessageTypes.text,
        'name': auth.user.name,
        'username': await auth.user.username,
        'uid': auth.user.uid,
        'reply_to_message': replyMessageId,
        'text': text,
        'time': Timestamp.now(),
      });
    }
    await _sendNotification(
        profilePicture: Core.auth.user.profilePicture,
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
        progress.value = 0.0;
        final link = await event.ref.getDownloadURL();
        await db.collection('messages').add({
          'type': MessageTypes.image,
          'name': auth.user.name,
          'username': await auth.user.username,
          'uid': auth.user.uid,
          'link': link,
          'description': description,
          'time': DateTime.now(),
        });
        await _sendNotification(
            chatName: chatName,
            name: auth.user.name,
            content: 'Imagine' + (description != null ? ' - $description' : ''),
            uid: auth.user.uid,
            chatType: chatType,
            profilePicture: Core.auth.user.profilePicture,
            photo: link);
        Navigator.of(context).pop();
      }
    });
  }

  Future _sendNotification({
    required String chatName,
    required String name,
    required String content,
    required String uid,
    required String chatType,
    required String? profilePicture,
    String? photo,
  }) async {
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
          'type': chatType,
          'profilePicture': profilePicture,
          'photo': photo,
        }
      }),
    );
  }
}
