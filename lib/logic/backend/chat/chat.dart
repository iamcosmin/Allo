import 'package:allo/components/chats/chat_messages_list.dart';
import 'package:allo/logic/backend/chat/messages.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    required BuildContext context,
    required WidgetRef ref,
    int? limit,
    DocumentSnapshot? startAfter,

    /// [lastIndex] is used to combine the lists with different indexes.
    int? lastIndex,
  }) async* {
    final messages = <Message>[];
    Stream<QuerySnapshot> query;
    final collection = Database.firestore
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
              final message = Message.get(
                documentSnapshot: docChanges.doc,
                replyData: replyData,
              );

              ref.read(animatedListKeyProvider).currentState?.insertItem(
                    calculateIndex(docChanges.newIndex, lastIndex),
                    duration: const Duration(milliseconds: 275),
                  );
              if (message != null) {
                messages.insert(docChanges.newIndex, message);
              }
              break;
            }
          case DocumentChangeType.modified:
            {
              final replyData = await returnReplyMessageData(
                initialDocumentSnapshot: docChanges.doc,
                chatId: chatId,
                context: context,
              );
              final message = Message.get(
                documentSnapshot: docChanges.doc,
                replyData: replyData,
              );
              if (message != null) {
                // ignore: invalid_use_of_protected_member
                ref.read(animatedListKeyProvider).currentState?.setState(() {
                  final index = calculateIndex(docChanges.newIndex, lastIndex);
                  messages[index] = message;
                });
              }
              break;
            }
          case DocumentChangeType.removed:
            {
              ref.read(animatedListKeyProvider).currentState?.removeItem(
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
