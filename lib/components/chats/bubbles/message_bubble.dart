import 'package:allo/logic/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'received.dart';
import 'sent.dart';

class MessageBubble extends HookWidget {
  final DocumentSnapshot data;
  final String pastUID;
  final String nextUID;
  final String chatType;
  final String chatId;
  final Color color;
  const MessageBubble({
    required Key key,
    required this.data,
    required this.chatId,
    required this.pastUID,
    required this.nextUID,
    required this.color,
    required this.chatType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final documentData = data.data() as Map;
    var uid = documentData['uid'] ?? documentData['senderUID'] ?? 'No UID';
    final auth = Core.auth;
    if (uid != auth.user.uid) {
      return ReceiveMessageBubble(
        chatType: chatType,
        key: UniqueKey(),
        pastUID: pastUID,
        nextUID: nextUID,
        chatId: chatId,
        data: data,
      );
    } else {
      return SentMessageBubble(
        key: UniqueKey(),
        pastUID: pastUID,
        nextUID: nextUID,
        chatId: chatId,
        data: data,
        color: color,
      );
    }
  }
}
