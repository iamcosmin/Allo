import 'package:allo/logic/models/messages.dart';
import 'package:allo/logic/models/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core.dart';

abstract class Chat {
  const Chat({
    required this.title,
    required this.id,
    required this.picture,
    required this.memberUids,
    required this.lastMessage,
  });
  final String title;
  final String id;
  final String picture;
  final List<dynamic> memberUids;
  final Message? lastMessage;

  static ChatType getType(Chat chat) {
    switch (chat.runtimeType) {
      case PrivateChat:
        return ChatType.private;
      case GroupChat:
        return ChatType.group;
      default:
        return ChatType.unsupported;
    }
  }
}

class UnsupportedChat extends Chat {
  const UnsupportedChat({
    super.title = '',
    super.id = '',
    super.picture = '',
    super.memberUids = const [],
    super.lastMessage,
  });
}

class PrivateChat extends Chat {
  const PrivateChat({
    required String name,
    required this.userId,
    required super.id,
    required super.memberUids,
    required super.lastMessage,
  }) : super(
          title: name,
          picture: 'gs://allo-ms.appspot.com/profilePictures/$userId.png',
        );
  final String userId;

  factory PrivateChat.fromDocumentSnapshot(
    DocumentSnapshot snapshot, {
    required Message? lastMessage,
  }) {
    // TODO: Convert this chunk to support the new log.
    final data = snapshot.data();
    if (data != null && data is Map<String, dynamic>) {
      final List members = data['members'];
      final memberUids = data['participants'];
      if (members.length == 2) {
        String name, uid;
        if (members[0]['uid'] != null &&
            members[0]['uid'] != Core.auth.user.userId) {
          name = members[0]['name'];
          uid = members[0]['uid'];
        } else if (members[1]['uid'] != null &&
            members[1]['uid'] != Core.auth.user.userId) {
          name = members[1]['name'];
          uid = members[1]['uid'];
        } else {
          throw Exception(
            'Conflict with the database. You have access to a chat that you are not a member of. This may be an issue with security rules. Please contact the administrator asap.',
          );
        }
        return PrivateChat(
          name: name,
          userId: uid,
          id: snapshot.id,
          memberUids: memberUids,
          lastMessage: lastMessage,
        );
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
    required super.title,
    required super.id,
    required super.memberUids,
    required super.lastMessage,
  }) : super(
          picture: 'gs://allo-ms.appspot.com/chats/$id.png',
        );

  factory GroupChat.fromDocumentSnapshot(
    DocumentSnapshot snapshot, {
    required Message? lastMessage,
  }) {
    final data = snapshot.data.call();
    if (data != null && data is Map) {
      return GroupChat(
        title: data['title'],
        id: snapshot.id,
        memberUids: data['participants'],
        lastMessage: lastMessage,
      );
    } else {
      throw Exception(
        "The retreived data is null or it isn't a map.",
      );
    }
  }
}
