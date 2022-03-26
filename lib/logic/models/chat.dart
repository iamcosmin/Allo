import 'package:allo/logic/models/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core.dart';

abstract class Chat {
  const Chat({required this.title, required this.id, required this.picture});
  final String title;
  final String id;
  final String picture;
}

class PrivateChat extends Chat {
  const PrivateChat({
    required String name,
    required this.userId,
    required String chatId,
  }) : super(
          title: name,
          id: chatId,
          picture: 'gs://allo-ms.appspot.com/profilePictures/$userId.png',
        );
  final String userId;

  factory PrivateChat.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();
    if (data != null && data is Map<String, dynamic>) {
      final List members = data['members'];
      if (members.length == 2) {
        String name, uid;
        if (members[0]['uid'] != null &&
            members[0]['uid'] != Core.auth.user.uid) {
          name = members[0]['name'];
          uid = members[0]['uid'];
        } else if (members[1]['uid'] != null &&
            members[1]['uid'] != Core.auth.user.uid) {
          name = members[1]['name'];
          uid = members[1]['uid'];
        } else {
          throw Exception(
            'Conflict with the database. You have access to a chat that you are not a member of. This may be an issue with security rules. Please contact the administrator asap.',
          );
        }
        return PrivateChat(name: name, userId: uid, chatId: snapshot.id);
      } else {
        throw Exception(
          'This is a private group, but it has more than 2 members. This does not comply with this version of the app.',
        );
      }
    } else {
      throw Exception(
        "The retreived data is null or it isn't a map.",
      );
    }
  }
}

class GroupChat extends Chat {
  const GroupChat({
    required String title,
    required String chatId,
  }) : super(
          title: title,
          id: chatId,
          picture: 'gs://allo-ms.appspot.com/chats/$chatId.png',
        );

  factory GroupChat.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data.call();
    if (data != null && data is Map) {
      return GroupChat(
        title: data['title'],
        chatId: snapshot.id,
      );
    } else {
      throw Exception(
        "The retreived data is null or it isn't a map.",
      );
    }
  }
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
