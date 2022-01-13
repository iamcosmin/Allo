import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:allo/logic/types.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

void deleteMessage(
    {required BuildContext context,
    required String chatId,
    required String messageId}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ștergere mesaj'),
      content: const Text('Sigur dorești să ștergi acest mesaj?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Anulează'),
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
                    icon: FluentIcons.delete_20_regular,
                    text: 'Mesajul a fost șters.');
              },
            );
          },
          child: const Text(
            'Șterge',
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    ),
  );
}

void textMessageOptions(
    BuildContext context, String messageId, String chatId, String messageText) {
  showMagicBottomSheet(
    context: context,
    title: 'Opțiuni mesaj',
    initialChildSize: 0.3,
    children: [
      ListTile(
        leading: const Icon(FluentIcons.copy_24_regular),
        title: const Text('Copiere mesaj'),
        onTap: () {
          Navigator.of(context).pop();
          Clipboard.setData(ClipboardData(text: messageText));
          Core.stub.showInfoBar(
            context: context,
            icon: FluentIcons.copy_24_regular,
            text: 'Mesajul a fost copiat.',
          );
        },
      ),
      ListTile(
        leading: const Icon(FluentIcons.delete_20_regular),
        title: const Text('Șterge mesaj'),
        onTap: () {
          Navigator.of(context).pop();
          deleteMessage(context: context, chatId: chatId, messageId: messageId);
        },
      ),
    ],
  );
}

void imageMessageOptions(
    BuildContext context, String messageId, String chatId) {
  showMagicBottomSheet(
    context: context,
    title: 'Opțiuni mesaj',
    initialChildSize: 0.2,
    children: [
      ListTile(
        leading: const Icon(FluentIcons.delete_20_regular),
        title: const Text('Șterge mesaj'),
        onTap: () {
          Navigator.of(context).pop();
          deleteMessage(context: context, chatId: chatId, messageId: messageId);
        },
      ),
    ],
  );
}

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

    final msgOpt = ref.watch(newMessageOptions);
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
                  onLongPress: () => msgOpt == true
                      ? textMessageOptions(context, messageId, chatId, text)
                      : bubbleMenu(context, messageId, chatId),
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
                  onLongPress: () => msgOpt == true
                      ? imageMessageOptions(context, messageId, chatId)
                      : bubbleMenu(context, messageId, chatId),
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
        child: CachedNetworkImage(
          imageUrl: imageUrl,
        ),
      ),
    );
  }
}
