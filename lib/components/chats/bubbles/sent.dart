import 'package:allo/logic/core.dart';
import 'package:allo/logic/types.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

void bubbleMenu(BuildContext context, String messageId, String chatId) {
  showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return ClipRRect(
          child: Material(
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        alignment: Alignment.topRight,
                        child: const Icon(
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
                                  const Duration(seconds: 1),
                                  () => Core.chat(chatId)
                                      .messages
                                      .deleteMessage(messageId: messageId),
                                );
                              },
                              child: ClipOval(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  alignment: Alignment.center,
                                  color: Colors.red,
                                  child: const Icon(
                                    FluentIcons.delete_16_regular,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
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
          ),
        );
      });
}

class SentMessageBubble extends HookWidget {
  const SentMessageBubble(
      {required Key key,
      required this.pastUID,
      required this.nextUID,
      required this.chatId,
      required this.color,
      required this.data})
      : super(key: key);
  final String pastUID;
  final String nextUID;
  final String chatId;
  final DocumentSnapshot data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final documentData = data.data() as Map;

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
    void change() =>
        selected.value == true ? selected.value = false : selected.value = true;
    final regexEmoji = RegExp(
        r'^(\u00a9|\u00ae|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$');
    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: Radius.circular(isSameSenderAsInPast ? 5 : 20),
      bottomRight: Radius.circular(isSameSenderAsInFuture ||
              (isSameSenderAsInFuture && isSameSenderAsInPast)
          ? 5
          : 20),
      bottomLeft: const Radius.circular(20),
    );
    return Padding(
      padding: EdgeInsets.only(
          bottom: (isSameSenderAsInFuture || nextUID == 'null') ? 1 : 15,
          right: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Chat bubble
              if (type == MessageTypes.text) ...[
                GestureDetector(
                  onTap: () => change(),
                  onLongPress: () => bubbleMenu(context, messageId, chatId),
                  child: Container(
                    decoration:
                        BoxDecoration(color: color, borderRadius: bubbleRadius),
                    padding: const EdgeInsets.all(8),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.4),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 2),
                      child: Text(
                        text,
                        style: TextStyle(
                            fontSize: regexEmoji.hasMatch(text) ? 30 : 16,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )
              ] else if (type == MessageTypes.image) ...[
                GestureDetector(
                  onTap: () => Core.navigation.push(
                    context: context,
                    route: ImageView(
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
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
            padding: const EdgeInsets.only(right: 5),
            height: selected.value || (isRead == true && nextUID == 'null')
                ? 20
                : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  isRead ? 'Citit' : 'Trimis',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
                const Padding(padding: EdgeInsets.only(left: 3)),
                Text(
                  time,
                  style: const TextStyle(
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
  final String imageUrl;
  const ImageView(this.imageUrl, {Key? key}) : super(key: key);
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
