import 'package:allo/logic/models/types.dart';

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
