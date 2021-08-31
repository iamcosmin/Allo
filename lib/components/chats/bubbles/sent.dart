import 'dart:math';

import 'package:allo/repositories/repositories.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

void bubbleMenu(BuildContext context, String messageId, String chatId) {
  final chat = context.read(Repositories.chats);
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: Container(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Icon(
                        FluentIcons.dismiss_circle_20_filled,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              Future.delayed(
                                  Duration(seconds: 1),
                                  () => chat.deleteMessage(
                                      messageId: messageId, chatId: chatId));
                            },
                            child: ClipOval(
                              child: Container(
                                height: 60,
                                width: 60,
                                alignment: Alignment.center,
                                color: Colors.red,
                                child: Icon(
                                  FluentIcons.delete_16_regular,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                'Șterge mesajul',
                                style: TextStyle(fontSize: 16),
                              )),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      });
}

class SentMessageBubble extends HookWidget {
  SentMessageBubble(
      {required Key key,
      required this.pastUID,
      required this.nextUID,
      required this.chatId,
      required this.data})
      : super(key: key);
  String pastUID;
  String nextUID;
  String chatId;
  DocumentSnapshot data;

  @override
  Widget build(BuildContext context) {
    final documentData = data.data() as Map;

    var name = documentData['name'] ?? documentData['senderName'] ?? 'No name';
    var uid = documentData['uid'] ?? documentData['senderUID'] ?? 'No UID';
    String text =
        documentData['text'] ?? documentData['messageTextContent'] ?? 'No text';
    var msSE = DateTime.fromMillisecondsSinceEpoch(
        (documentData['time'] as Timestamp).millisecondsSinceEpoch);
    bool isRead = documentData['read'] ?? false;
    var time = DateFormat.Hm().format(msSE);
    var messageId = data.id;
    var type = documentData['type'];

    var isSameSenderAsInPast = uid == pastUID;
    var isSameSenderAsInFuture = uid == nextUID;

    final selected = useState(false);
    final navigation = useProvider(Repositories.navigation);
    void change() =>
        selected.value == true ? selected.value = false : selected.value = true;
    final regexEmoji = RegExp(
        r'^(\u00a9|\u00ae|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$');
    final bubbleRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(isSameSenderAsInPast ? 5 : 20),
      bottomRight: Radius.circular(isSameSenderAsInFuture ||
              (isSameSenderAsInFuture && isSameSenderAsInPast)
          ? 5
          : 20),
      bottomLeft: Radius.circular(20),
    );
    return Padding(
      padding:
          EdgeInsets.only(bottom: isSameSenderAsInFuture ? 1 : 15, right: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Chat bubble
              if (type == MessageTypes.TEXT) ...[
                GestureDetector(
                  onTap: () => change(),
                  onLongPress: () => bubbleMenu(context, messageId, chatId),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue, borderRadius: bubbleRadius),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.4),
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 2),
                      child: Text(
                        text,
                        style: TextStyle(
                            fontSize: regexEmoji.hasMatch(text) ? 30 : 16),
                      ),
                    ),
                  ),
                )
              ] else if (type == MessageTypes.IMAGE) ...[
                GestureDetector(
                  onTap: () => navigation.push(
                    context,
                    ImageView(
                      documentData['link'],
                    ),
                  ),
                  onLongPress: () => bubbleMenu(context, messageId, chatId),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: bubbleRadius),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.4),
                    child: ClipRRect(
                      borderRadius: bubbleRadius,
                      child: Hero(
                        tag: documentData['link'],
                        child: CachedNetworkImage(
                          imageUrl: documentData['link'],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ],
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
            padding: EdgeInsets.only(right: 5),
            height: selected.value || (isRead == true && nextUID == 'null')
                ? 20
                : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  isRead ? 'Citit' : 'Trimis',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.only(left: 3)),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImageView extends HookWidget {
  final imageUrl;
  ImageView(this.imageUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
          ),
        ),
      ),
    );
  }
}
