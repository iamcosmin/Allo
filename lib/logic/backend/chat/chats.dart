import 'package:allo/logic/backend/chat/chat.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/messages.dart';

class ChatsLogic {
  ChatsLogic();

  Chats chat(chatId) => Chats(chatId: chatId);

  ///* Explanation of the logic below.
  ///
  /// We provide a [uid] for the user that the chat is created with, and a [type]
  /// (for future references). The database checks if there are any documents
  /// (in this case chats) that are the same type as [type], that have the
  /// [uid] in the participants array, and that have the currently authenticated
  /// user's uid in the participants array, all at the same time.
  ///
  /// We limit the query to one, if there is one chat already made it is clear that
  /// we cannot create another chat with the same user.
  ///
  /// If the returned list is empty (there are no chats with that person), we return
  /// [true], otherwise we return [false].
  Future<bool> _checkIfChatAlreadyExists({
    required String uid,
    ChatType type = ChatType.private,
  }) async {
    if (type == ChatType.private) {
      final query = await Database.firestore
          .collection('chats')
          .where('type', isEqualTo: type.name)
          .where('participants', isEqualTo: [uid, Core.auth.user.userId])
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      throw Exception(
        'For the moment, you cannot check if a group chat exists based on member uids.',
      );
    }
  }

  // Future<void> createNewChat({
  //   required String uid,
  //   ChatType type = ChatType.private,
  // }) async {
  //   if (type == ChatType.private) {
  //     if (await _checkIfChatAlreadyExists(uid: uid, type: type)) {
  //       await Database.firestore.collection('chats').add(
  //         {
  //           'type': 'private',
  //           'participants': [
  //             uid,
  //             Core.auth.user.userId,
  //           ],
  //         },
  //       );
  //     }
  //   } else {
  //     throw Exception(
  //       "Hmm... For now, you can't create group chats, only private ones.",
  //     );
  //   }
  // }

  final chatListProvider = FutureProvider<List<Chat>>((ref) {
    return Core.chats.getChatsList();
  });

  @Deprecated('Yes')
  Future<Message?> getLastMessage(String chatId) async {
    final query = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(1)
        .get();
    if (query.docs.length > 1) {
      throw Exception(
        'Limitations imply that there should be only one document returned from the query.',
      );
    }
    return Message.get(
      documentSnapshot: query.docs[0],
      replyData: null,
    );
  }

  Future<List<Chat>> getChatsList() async {
    final currentUid = Core.auth.user.userId;
    final chats = <Chat>[];
    if (FirebaseAuth.instance.currentUser == null) {
      return [];
    }
    final rawChats = await Database.firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .get();
    if (rawChats.docs.isNotEmpty) {
      for (final rawChat in rawChats.docs) {
        final rawChatInfo = rawChat.data();
        // final lastMessage = await getLastMessage(rawChat.id);
        const lastMessage = null;
        final chatType = ChatType.values.firstWhere(
          (element) => element.name == rawChatInfo['type'],
        );
        final chatMembers = rawChatInfo['members'];
        switch (chatType) {
          case ChatType.private:
            for (final member in chatMembers) {
              final memberUid = member['uid'];

              if (memberUid != null && memberUid != currentUid) {
                chats.add(
                  PrivateChat.fromDocumentSnapshot(
                    rawChat,
                    lastMessage: lastMessage,
                  ),
                );
              }
            }
            break;
          case ChatType.group:
            chats.add(
              GroupChat.fromDocumentSnapshot(
                rawChat,
                lastMessage: lastMessage,
              ),
            );
            break;
          case ChatType.unsupported:
            break;
        }
      }
    }
    return chats;
  }

  Future<void> createNewChat({
    required ChatType chatType,

    /// List of user id's of the participants
    required List<Participant> participants,
  }) async {
    // In Allo, chats have the following structure in the database:
    /*
      (chatId) --------------- [messages] ----------------- (list of messages)
      
      params:
        members: array of map that mandatory contains name and uid.
        participants: array of string that resembles participants' uid
        theme: integer with hex value of chosen theme color
        type: private | group, mandatory
    */

    if (chatType == ChatType.unsupported) {
      throw Exception('Cannot create a chat of unsupported type.');
    }

    if (chatType == ChatType.group || participants.length > 1) {
      throw Exception('Creating a group chat is unsupported for now.');
    }

    if (FirebaseAuth.instance.currentUser?.uid == null) {
      throw Exception(
        'Cannot create a chat that does not contain the current user.',
      );
    }

    if (await _checkIfChatAlreadyExists(uid: participants[0].uid)) {
      throw Exception('One user can only have one chat with another user.');
    }

    final db = FirebaseFirestore.instance;
    final chat = {
      'type': chatType.name,
      'participants': [
        FirebaseAuth.instance.currentUser!.uid,
        for (var participant in participants) ...[participant.uid]
      ],
      'members': [
        {
          'name': FirebaseAuth.instance.currentUser?.displayName,
          'uid': FirebaseAuth.instance.currentUser?.uid,
        },
        for (var participant in participants) ...[
          {'name': participant.name, 'uid': participant.uid}
        ]
      ]
    };
    await db.collection('chats').add(chat);
  }

  // Please note that creating a chat does not notify the other user, as it hasn't subscribed yet to the chat.
}

class CreateChatException implements Exception {
  const CreateChatException(this.cause);
  final CreateChatExceptionCause cause;
}

enum CreateChatExceptionCause {
  selfChatNotAllowed,
  chatAlreadyExists,
}

class Participant {
  const Participant({required this.name, required this.uid});
  final String name;
  final String uid;
}
