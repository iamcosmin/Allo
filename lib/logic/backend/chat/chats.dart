import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsLogic {
  const ChatsLogic();

  Future<List<Chat>?> getChatsList() async {
    final uid = Core.auth.user.uid;
    final documents = await FirebaseFirestore.instance
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
                  print(chat);
                  chats.add(PrivateChat.fromDocumentSnapshot(chat));
                }
              }
              break;
            }
          case ChatType.group:
            {
              print(chat);
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
