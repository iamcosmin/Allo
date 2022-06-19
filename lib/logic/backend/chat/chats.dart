import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/types.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatsLogic {
  ChatsLogic();

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
          .where('type', isEqualTo: 'private')
          .where('participants', arrayContains: uid)
          .where('participants', arrayContains: Core.auth.user.uid)
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

  Future<void> createNewChat({
    required String uid,
    ChatType type = ChatType.private,
  }) async {
    if (type == ChatType.private) {
      if (await _checkIfChatAlreadyExists(uid: uid, type: type)) {
        await Database.firestore.collection('chats').add(
          {
            'type': 'private',
            'participants': [
              uid,
              Core.auth.user.uid,
            ],
          },
        );
      }
    } else {
      throw Exception(
        "Hmm... For now, you can't create group chats, only private ones.",
      );
    }
  }

  final chatListProvider = FutureProvider<List<Chat>>((ref) {
    return Core.chats.getChatsList();
  });

  Future<List<Chat>> getChatsList() async {
    final currentUid = Core.auth.user.uid;
    final chats = <Chat>[];
    if (FirebaseAuth.instance.currentUser == null) {
      return [];
    }
    final rawChats = await Database.firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .get();
    print('HERE!');
    if (rawChats.docs.isNotEmpty) {
      for (final rawChat in rawChats.docs) {
        final rawChatInfo = rawChat.data();
        final chatType = ChatType.values.firstWhere(
          (element) => element.name == rawChatInfo['type'],
        );
        final chatMembers = rawChatInfo['members'];
        switch (chatType) {
          case ChatType.private:
            for (final member in chatMembers) {
              final memberUid = member['uid'];

              if (memberUid != null && memberUid != currentUid) {
                chats.add(PrivateChat.fromDocumentSnapshot(rawChat));
              }
            }
            break;
          case ChatType.group:
            chats.add(GroupChat.fromDocumentSnapshot(rawChat));
            break;
          case ChatType.unsupported:
            break;
        }
      }
    }
    return chats;
  }
}
