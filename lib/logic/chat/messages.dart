import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String name;
  final String userId;
  final String username;
  final String id;
  final Timestamp timestamp;
  final Map<String, dynamic> data;
  const Message({
    required this.name,
    required this.userId,
    required this.username,
    required this.id,
    required this.timestamp,
    required this.data,
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
      required Map<String, dynamic> data,
      required this.read,
      required this.text,
      this.reply})
      : super(
            id: id,
            name: name,
            timestamp: timestamp,
            userId: userId,
            username: username,
            data: data);
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
      required Map<String, dynamic> data,
      required this.read,
      required this.link,
      this.reply})
      : super(
          id: id,
          name: name,
          timestamp: timestamp,
          userId: userId,
          username: username,
          data: data,
        );
  final bool read;
  final String link;
  final ReplyToMessage? reply;
}
