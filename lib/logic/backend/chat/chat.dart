import 'package:allo/logic/backend/chat/messages.dart';
import 'package:allo/logic/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Stream<List<Message>> streamChatMessages({
    required GlobalKey<AnimatedListState> listKey,
    required BuildContext context,
    int? limit,
    DocumentSnapshot? startAfter,

    /// [lastIndex] is used to combine the lists with different indexes.
    int? lastIndex,
  }) async* {
    final messages = <Message>[];
    Stream<QuerySnapshot> query;
    final collection = FirebaseFirestore.instance
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
    await for (final querySnapshot in query) {
      for (final docChanges in querySnapshot.docChanges) {
        switch (docChanges.type) {
          case DocumentChangeType.added:
            {
              final replyData = await returnReplyMessageData(
                initialDocumentSnapshot: docChanges.doc,
                chatId: chatId,
                context: context,
              );
              final message = convertToMessage(
                documentSnapshot: docChanges.doc,
                context: context,
                replyData: replyData,
              );

              listKey.currentState?.insertItem(
                calculateIndex(docChanges.newIndex, lastIndex),
                duration: const Duration(milliseconds: 275),
              );
              messages.insert(docChanges.newIndex, message);
              break;
            }
          case DocumentChangeType.modified:
            {
              final replyData = await returnReplyMessageData(
                initialDocumentSnapshot: docChanges.doc,
                chatId: chatId,
                context: context,
              );
              final message = convertToMessage(
                documentSnapshot: docChanges.doc,
                context: context,
                replyData: replyData,
              );
              // ignore: invalid_use_of_protected_member
              listKey.currentState?.setState(() {
                final index = calculateIndex(docChanges.newIndex, lastIndex);
                messages[index] = message;
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
                      curve: Curves.easeIn,
                      parent: animation,
                    ),
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
