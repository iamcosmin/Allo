import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/types.dart';

class ChatsLogic {
  const ChatsLogic();

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
      final query = await Database.storage
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
        await Database.storage.collection('chats').add(
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

  Future<List<Chat>?> getChatsList() async {
    final uid = Core.auth.user.uid;
    final documents = await Database.storage
        .collection('chats')
        .where('participants', arrayContains: uid)
        .get();
    final chats = <Chat>[];
    if (documents.docs.isNotEmpty) {
      for (final chat in documents.docs) {
        final chatInfo = chat.data();
        // Check the chat type to sort accordingly
        switch (getChatTypeFromString(chatInfo['type'])) {
          case ChatType.private:
            {
              for (final member in chatInfo['members']) {
                if (member['uid'] != null &&
                    member['uid'] != Core.auth.user.uid) {
                  chats.add(PrivateChat.fromDocumentSnapshot(chat));
                }
              }
              break;
            }
          case ChatType.group:
            {
              chats.add(
                GroupChat.fromDocumentSnapshot(chat),
              );
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
}
