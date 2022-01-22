import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:allo/logic/types.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

void deleteMessage(
    {required BuildContext context,
    required String chatId,
    required String messageId}) {
  final locales = S.of(context);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(locales.deleteMessageTitle),
      content: Text(locales.deleteMessageDescription),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(locales.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Future.delayed(
              const Duration(seconds: 1),
              () {
                Core.chat(chatId).messages.deleteMessage(messageId: messageId);
                Core.stub.showInfoBar(
                    context: context,
                    icon: Icons.delete_outline,
                    text: locales.messageDeleted);
              },
            );
          },
          child: Text(
            locales.delete,
            style: const TextStyle(color: Colors.red),
          ),
        )
      ],
    ),
  );
}

void textMessageOptions(BuildContext context, String messageId, String chatId,
    String messageText, WidgetRef ref) {
  final replies = ref.watch(repliesDebug);
  final editMessage = ref.watch(editMessageDebug);
  final locales = S.of(context);
  showMagicBottomSheet(
    context: context,
    title: locales.messageOptions,
    children: [
      if (replies) ...[
        ListTile(
          leading: const Icon(Icons.reply_outlined),
          title: Text(locales.reply),
          onTap: () {
            Navigator.of(context).pop();
            Core.stub.showInfoBar(
              context: context,
              icon: Icons.info_outlined,
              text: locales.comingSoon,
            );
          },
        ),
      ],
      ListTile(
        leading: const Icon(Icons.copy_outlined),
        title: Text(locales.copy),
        onTap: () {
          Navigator.of(context).pop();
          Clipboard.setData(ClipboardData(text: messageText));
          Core.stub.showInfoBar(
            context: context,
            icon: Icons.copy_outlined,
            text: locales.messageCopied,
          );
        },
      ),
      if (editMessage) ...[
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(locales.edit),
          onTap: () {
            Navigator.of(context).pop();
            Core.stub.showInfoBar(
              context: context,
              icon: Icons.info_outlined,
              text: locales.comingSoon,
            );
          },
        ),
      ],
      ListTile(
        leading: const Icon(Icons.delete_outlined),
        title: Text(locales.delete),
        onTap: () {
          Navigator.of(context).pop();
          deleteMessage(context: context, chatId: chatId, messageId: messageId);
        },
      ),
    ],
  );
}

void imageMessageOptions(
    BuildContext context, String messageId, String chatId, WidgetRef ref) {
  final replies = ref.watch(repliesDebug);
  final locales = S.of(context);
  showMagicBottomSheet(
    context: context,
    title: locales.messageOptions,
    children: [
      if (replies) ...[
        ListTile(
          leading: const Icon(Icons.reply_outlined),
          title: Text(locales.reply),
          onTap: () {
            Navigator.of(context).pop();
            Core.stub.showInfoBar(
              context: context,
              icon: Icons.info_outlined,
              text: locales.comingSoon,
            );
          },
        ),
      ],
      ListTile(
        leading: const Icon(Icons.delete_outlined),
        title: Text(locales.delete),
        onTap: () {
          Navigator.of(context).pop();
          deleteMessage(context: context, chatId: chatId, messageId: messageId);
        },
      ),
    ],
  );
}

class SentMessageBubble extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
    final locales = S.of(context);
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
                InkWell(
                  highlightColor: const Color(0x00000000),
                  focusColor: const Color(0x00000000),
                  hoverColor: const Color(0x00000000),
                  splashColor: const Color(0x00000000),
                  onTap: () => change(),
                  onLongPress: () =>
                      textMessageOptions(context, messageId, chatId, text, ref),
                  child: Container(
                    decoration:
                        BoxDecoration(color: color, borderRadius: bubbleRadius),
                    padding: const EdgeInsets.all(8),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.4),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 2),
                      child: Linkify(
                        text: text,
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            await launch(link.url);
                          } else {
                            throw 'Could not launch $link';
                          }
                        },
                        style: TextStyle(
                            fontSize: regexEmoji.hasMatch(text) ? 30 : 16,
                            color: Colors.white),
                        linkStyle: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )
              ] else if (type == MessageTypes.image) ...[
                InkWell(
                  highlightColor: const Color(0x00000000),
                  focusColor: const Color(0x00000000),
                  hoverColor: const Color(0x00000000),
                  splashColor: const Color(0x00000000),
                  onTap: () => Core.navigation.push(
                    context: context,
                    route: ImageView(
                      documentData['link'],
                    ),
                  ),
                  onLongPress: () =>
                      imageMessageOptions(context, messageId, chatId, ref),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: bubbleRadius),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.4),
                    child: ClipRRect(
                      borderRadius: bubbleRadius,
                      child: CachedNetworkImage(
                        imageUrl: documentData['link'],
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
                  isRead ? locales.read : locales.sent,
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
        child: CachedNetworkImage(
          imageUrl: imageUrl,
        ),
      ),
    );
  }
}
