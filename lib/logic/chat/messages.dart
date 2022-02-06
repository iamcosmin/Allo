import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Message {
  final String name;
  final String userId;
  final String username;
  final String id;
  final Timestamp timestamp;
  final DocumentSnapshot documentSnapshot;
  const Message({
    required this.name,
    required this.userId,
    required this.username,
    required this.id,
    required this.timestamp,
    required this.documentSnapshot,
  });
}

class ReplyToMessage {
  const ReplyToMessage({required this.name, required this.description});
  final String name;
  final String description;
}

class TextMessage extends Message {
  const TextMessage(
      {required String name,
      required String userId,
      required String username,
      required String id,
      required Timestamp timestamp,
      required DocumentSnapshot documentSnapshot,
      required this.read,
      required this.text,
      this.reply})
      : super(
            id: id,
            name: name,
            timestamp: timestamp,
            userId: userId,
            username: username,
            documentSnapshot: documentSnapshot);
  final bool read;
  final String text;
  final ReplyToMessage? reply;
}

class ImageMessage extends Message {
  const ImageMessage(
      {required String name,
      required String userId,
      required String username,
      required String id,
      required Timestamp timestamp,
      required DocumentSnapshot documentSnapshot,
      required this.read,
      required this.link,
      this.reply})
      : super(
          id: id,
          name: name,
          timestamp: timestamp,
          userId: userId,
          username: username,
          documentSnapshot: documentSnapshot,
        );
  final bool read;
  final String link;
  final ReplyToMessage? reply;
}
