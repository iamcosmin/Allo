import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/backend/database.dart';
import 'package:allo/logic/models/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

/// Converts a [DocumentSnapshot] into one of the following:
/// [TextMessage] if the type is [MessageType.text],
/// [ImageMessage] if the type is [MessageType.image],
/// [UnsupportedMessage] if the type of the message on the remote server does
/// not have a match on the client.
Message convertToMessage({
  required DocumentSnapshot documentSnapshot,
  required ReplyMessageData? replyData,
  required BuildContext context,
}) {
  final data = (documentSnapshot.data() != null
      ? documentSnapshot.data()!
      : throw Exception(
          'The provided documentSnapshot does not have any data.',
        )) as Map<String, dynamic>;
  final messageType = getMessageType(data['type']);

  if (messageType == MessageType.text) {
    return TextMessage.fromDocumentSnapshot(
      documentSnapshot: documentSnapshot,
      replyData: replyData,
    );
  } else if (messageType == MessageType.image) {
    return ImageMessage.fromDocumentSnapshot(
      documentSnapshot: documentSnapshot,
      replyData: replyData,
    );
  } else {
    return UnsupportedMessage.fromDocumentSnapshot(
      documentSnapshot: documentSnapshot,
    );
  }
}

/// Retreives a [ReplyMessageData] if [initialDocumentSnapshot] contains
/// a replied message's id, otherwise returns null.
Future<ReplyMessageData?> returnReplyMessageData({
  required DocumentSnapshot initialDocumentSnapshot,
  required String chatId,
  required BuildContext context,
}) async {
  final data = (initialDocumentSnapshot.data() != null
      ? initialDocumentSnapshot.data()!
      : throw Exception(
          'The provided initialDocumentSnapshot does not have any data.',
        )) as Map<String, dynamic>;
  if (data['reply_to_message'] != null) {
    final replySnapshot = await Database.storage
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(data['reply_to_message'])
        .get();
    final replyMessage = convertToMessage(
      documentSnapshot: replySnapshot,
      context: context,
      replyData: null,
    );
    return ReplyMessageData.fromMessage(
      message: replyMessage,
      context: context,
    );
  } else {
    return null;
  }
}

abstract class Message {
  final String name;
  final String userId;
  final String username;
  final String id;
  final Timestamp timestamp;
  final DocumentSnapshot documentSnapshot;
  final bool read;
  const Message({
    required this.name,
    required this.userId,
    required this.username,
    required this.id,
    required this.timestamp,
    required this.documentSnapshot,
    required this.read,
  });
}

class ReplyMessageData {
  const ReplyMessageData({required this.name, required this.description});
  final String name;
  final String description;

  factory ReplyMessageData.fromMessage({
    required Message message,
    required BuildContext context,
  }) {
    if (message is TextMessage) {
      return ReplyMessageData(
        name: message.name,
        description: message.text,
      );
    } else if (message is ImageMessage) {
      return ReplyMessageData(
        name: message.name,
        description: S.of(context).image,
      );
    } else {
      return ReplyMessageData(
        name: message.name,
        description: S.of(context).unsupported,
      );
    }
  }
}

class TextMessage extends Message {
  const TextMessage({
    required super.name,
    required super.userId,
    required super.username,
    required super.id,
    required super.timestamp,
    required super.documentSnapshot,
    required super.read,
    required this.text,
    this.reply,
  });
  final String text;
  final ReplyMessageData? reply;
  factory TextMessage.fromDocumentSnapshot({
    required DocumentSnapshot documentSnapshot,
    ReplyMessageData? replyData,
  }) {
    final data = (documentSnapshot.data() != null
        ? documentSnapshot.data()!
        : throw Exception('This cannot be null')) as Map<String, dynamic>;
    return TextMessage(
      name: data['name'],
      userId: data['uid'],
      username: data['username'],
      id: documentSnapshot.id,
      timestamp: data['time'],
      read: data['read'] ?? false,
      text: data['text'],
      documentSnapshot: documentSnapshot,
      reply: replyData,
    );
  }
}

class ImageMessage extends Message {
  const ImageMessage({
    required super.name,
    required super.userId,
    required super.username,
    required super.id,
    required super.timestamp,
    required super.documentSnapshot,
    required super.read,
    required this.link,
    this.reply,
  });
  final String link;
  final ReplyMessageData? reply;

  factory ImageMessage.fromDocumentSnapshot({
    required DocumentSnapshot documentSnapshot,
    ReplyMessageData? replyData,
  }) {
    final data = (documentSnapshot.data() != null
        ? documentSnapshot.data()!
        : throw Exception(
            'The provided documentSnapshot does not have any data.',
          )) as Map<String, dynamic>;
    return ImageMessage(
      name: data['name'],
      userId: data['uid'],
      username: data['username'],
      id: documentSnapshot.id,
      timestamp: data['time'],
      read: data['read'] ?? false,
      link: data['link'],
      documentSnapshot: documentSnapshot,
      reply: replyData,
    );
  }
}

class UnsupportedMessage extends Message {
  UnsupportedMessage({
    required super.name,
    required super.userId,
    required super.username,
    required super.id,
    required super.timestamp,
    required super.documentSnapshot,
    required super.read,
  });

  factory UnsupportedMessage.fromDocumentSnapshot({
    required DocumentSnapshot documentSnapshot,
  }) {
    final data =
        documentSnapshot.data() as Map<String, dynamic>? ?? (throw Exception());
    return UnsupportedMessage(
      name: data['name'],
      userId: data['uid'],
      username: data['username'],
      id: documentSnapshot.id,
      timestamp: data['time'],
      read: data['read'] ?? false,
      documentSnapshot: documentSnapshot,
    );
  }
}
