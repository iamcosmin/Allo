import 'package:allo/repositories/chats_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:allo/components/person_picture.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'received.dart';
import 'sent.dart';

class MessageBubble extends HookWidget {
  DocumentSnapshot data;
  String pastUID;
  String nextUID;
  String chatType;
  String chatId;
  MessageBubble({
    required Key key,
    required this.data,
    required this.chatId,
    required this.pastUID,
    required this.nextUID,
    required this.chatType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final documentData = data.data() as Map;
    var uid = documentData['uid'] ?? documentData['senderUID'] ?? 'No UID';
    final auth = useProvider(Repositories.auth);
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
      );
    }
  }
}