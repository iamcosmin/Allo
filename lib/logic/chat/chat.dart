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

abstract class Chat {
  const Chat({required this.title, required this.id, required this.picture});
  final String title;
  final String id;
  final String picture;
}

class PrivateChat extends Chat {
  const PrivateChat(
      {required String name, required this.userId, required String chatId})
      : super(
          title: name,
          id: chatId,
          picture: 'gs://allo-ms.appspot.com/profilePictures/$userId.png',
        );
  final String userId;
}

class GroupChat extends Chat {
  const GroupChat({required String title, required String chatId})
      : super(
          title: title,
          id: chatId,
          picture: 'gs://allo-ms.appspot.com/chats/$chatId.png',
        );
}

ChatType? getChatTypeFromString(String chatType) {
  switch (chatType) {
    case 'private':
      {
        return ChatType.private;
      }
    case 'group':
      {
        return ChatType.group;
      }
    default:
      {
        return null;
      }
  }
}

String getStringFromChatType(ChatType chatType) {
  if (chatType == ChatType.private) {
    return 'private';
  } else {
    return 'group';
  }
}

ChatType getChatTypeFromType(Chat chat) {
  if (chat is PrivateChat) {
    return ChatType.private;
  } else {
    return ChatType.group;
  }
}

int calculateIndex(int index, int? lastIndex) {
  if (lastIndex != null) {
    return index + lastIndex;
  } else {
    return index;
  }
}

class Chats {
  Chats({required this.chatId});
  final String chatId;

  Messages get messages => Messages(chatId: chatId);

  Future<List<Chat>?> getChatsList() async {
    final _uid = Core.auth.user.uid;
    final _documents = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: _uid)
        .get();
    var chats = <Chat>[];
    if (_documents.docs.isNotEmpty) {
      for (var chat in _documents.docs) {
        var chatInfo = chat.data();
        String? _name, _userId;
        // Check the chat type to sort accordingly
        switch (getChatTypeFromString(chatInfo['type'])) {
          case ChatType.private:
            {
              for (var member in chatInfo['members']) {
                if (member['uid'] != Core.auth.user.uid) {
                  _name = member['name'];
                  _userId = member['uid'];
                }
              }
              if (_userId != null) {
                chats.add(PrivateChat(
                    name: _name ?? '???', userId: _userId, chatId: chat.id));
              }
              break;
            }
          case ChatType.group:
            {
              _name = chatInfo['title'];
              chats.add(GroupChat(title: _name ?? '', chatId: chat.id));
              break;
            }
          default:
            {
              break;
            }
        }
      }
    }
    return chats.isNotEmpty ? chats : null;
  }

  Stream<List<Message>> streamChatMessages(
      {required GlobalKey<AnimatedListState> listKey,
      int? limit,
      DocumentSnapshot? startAfter,

      /// [lastIndex] is used to combine the lists with different indexes.
      int? lastIndex}) async* {
    var messages = <Message>[];
    Stream<QuerySnapshot> query;
    var collection = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(limit ?? 30);
    if (startAfter != null) {
      query = collection.startAfterDocument(startAfter).snapshots();
    } else {
      query = collection.snapshots();
    }
    await for (var querySnapshot in query) {
      for (var docChanges in querySnapshot.docChanges) {
        switch (docChanges.type) {
          case DocumentChangeType.added:
            {
              final data = docChanges.doc.data() as Map<String, dynamic>;
              Message? message;
              switch (data['type']) {
                case MessageTypes.text:
                  {
                    DocumentSnapshot replyQuery;
                    Map<String, dynamic>? replyData;
                    if (data['reply_to_message'] != null) {
                      replyQuery = await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(data['reply_to_message'])
                          .get();
                      replyData = replyQuery.data() as Map<String, dynamic>?;
                    }
                    message = TextMessage(
                      name: data['name'],
                      userId: data['uid'],
                      username: data['username'],
                      id: docChanges.doc.id,
                      timestamp: data['time'],
                      read: data['read'] ?? false,
                      text: data['text'],
                      documentSnapshot: docChanges.doc,
                      reply: replyData == null
                          ? null
                          : ReplyToMessage(
                              name: replyData['name'] ?? 'Solve later',
                              description: replyData['text'] ?? 'Solve later',
                            ),
                    );
                    break;
                  }
                case MessageTypes.image:
                  {
                    DocumentSnapshot replyQuery;
                    Map<String, dynamic>? replyData;
                    if (data['reply_to_message'] != null) {
                      replyQuery = await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(data['reply_to_message'])
                          .get();
                      replyData = replyQuery.data() as Map<String, dynamic>?;
                    }
                    message = ImageMessage(
                      name: data['name'],
                      userId: data['uid'],
                      username: data['username'],
                      id: docChanges.doc.id,
                      timestamp: data['time'],
                      read: data['read'] ?? false,
                      link: data['link'],
                      documentSnapshot: docChanges.doc,
                      reply: replyData == null
                          ? null
                          : ReplyToMessage(
                              name: replyData['name'] ?? 'Solve later',
                              description:
                                  replyData['description'] ?? 'Solve later',
                            ),
                    );
                    break;
                  }
              }
              if (message != null) {
                listKey.currentState?.insertItem(
                    calculateIndex(docChanges.newIndex, lastIndex),
                    duration: const Duration(milliseconds: 275));
                messages.insert(docChanges.newIndex, message);
              }
              break;
            }
          case DocumentChangeType.modified:
            {
              final data = docChanges.doc.data() as Map<String, dynamic>;
              Message? message;
              switch (data['type']) {
                case MessageTypes.text:
                  {
                    DocumentSnapshot replyQuery;
                    Map<String, dynamic>? replyData;
                    if (data['reply_to_message'] != null) {
                      replyQuery = await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(data['reply_to_message'])
                          .get();
                      replyData = replyQuery.data() as Map<String, dynamic>?;
                    }
                    message = TextMessage(
                      name: data['name'],
                      userId: data['uid'],
                      username: data['username'],
                      id: docChanges.doc.id,
                      timestamp: data['time'],
                      read: data['read'],
                      text: data['text'],
                      documentSnapshot: docChanges.doc,
                      reply: replyData == null
                          ? null
                          : ReplyToMessage(
                              name: replyData['name'],
                              description: replyData['text'],
                            ),
                    );
                    break;
                  }
                case MessageTypes.image:
                  {
                    DocumentSnapshot replyQuery;
                    Map<String, dynamic>? replyData;
                    if (data['reply_to_message'] != null) {
                      replyQuery = await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(data['reply_to_message'])
                          .get();
                      replyData = replyQuery.data() as Map<String, dynamic>?;
                    }
                    message = ImageMessage(
                      name: data['name'],
                      userId: data['uid'],
                      username: data['username'],
                      id: docChanges.doc.id,
                      timestamp: data['time'],
                      read: data['read'],
                      link: data['link'],
                      documentSnapshot: docChanges.doc,
                      reply: replyData == null
                          ? null
                          : ReplyToMessage(
                              name: replyData['name'],
                              description: replyData['description'],
                            ),
                    );
                    break;
                  }
              }
              listKey.currentState?.setState(() {
                message != null
                    ? messages[calculateIndex(docChanges.newIndex, lastIndex)] =
                        message
                    : null;
              });
              break;
            }
          case DocumentChangeType.removed:
            {
              listKey.currentState?.removeItem(
                calculateIndex(docChanges.oldIndex, lastIndex),
                (context, animation) => SizeTransition(
                  axisAlignment: -1.0,
                  sizeFactor: animation,
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                        curve: Curves.easeIn, parent: animation),
                  ),
                ),
              );
              messages.removeAt(docChanges.oldIndex);
              break;
            }
        }
      }
      yield messages;
    }
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
