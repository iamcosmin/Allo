import 'package:allo/components/chats/bubbles/sent.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:allo/logic/theme.dart';
import 'package:allo/logic/types.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../person_picture.dart';

void textMessageOptions(BuildContext context, String messageId, String chatId,
    String messageText, WidgetRef ref) {
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
              icon: Icons.info_outline,
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
              icon: Icons.info_outline,
              text: locales.comingSoon,
            );
          },
        ),
      ],
    ],
  );
}

class ReceiveMessageBubble extends HookConsumerWidget {
  // If the nextUID == senderUID, we need to keep the name and to reduce
  // the bottom padding, also eliminate the profile picture as we will put it
  // on the last message.
  // If the pastUID == senderUID, we need to eliminate the name and change bubble
  // characteristics
  const ReceiveMessageBubble(
      {Key? key,
      required this.pastUID,
      required this.nextUID,
      required this.chatId,
      required this.chatType,
      required this.data})
      : super(key: key);
  final String pastUID;
  final String nextUID;
  final String chatId;
  final String chatType;
  final DocumentSnapshot data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final locales = S.of(context);

    var isSameSenderAsInPast = uid == pastUID;
    var isSameSenderAsInFuture = uid == nextUID;
    final colors = ref.watch(colorsProvider);
    final selected = useState(false);
    final profilePicture = useState<String?>(null);
    final bubbleRadius = BorderRadius.only(
      topLeft: Radius.circular(isSameSenderAsInPast ? 5 : 20),
      bottomLeft: Radius.circular(isSameSenderAsInFuture ||
              (isSameSenderAsInFuture && isSameSenderAsInPast)
          ? 5
          : 20),
      topRight: const Radius.circular(20),
      bottomRight: const Radius.circular(20),
    );
    final regexEmoji = RegExp(
        r'^(\u00a9|\u00ae|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$');
    void change() =>
        selected.value == true ? selected.value = false : selected.value = true;
    useEffect(() {
      if (!isRead) {
        Core.chat(chatId).messages.markAsRead(messageId: messageId);
      }
      Future.microtask(() async {
        profilePicture.value = await Core.auth.getUserProfilePicture(uid);
      });
    }, const []);

    return Container(
      padding: EdgeInsets.only(
          bottom: (isSameSenderAsInFuture || nextUID == 'null') ? 1 : 15,
          left: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Profile picture
              if (chatType == ChatType.group) ...[
                if (!isSameSenderAsInFuture) ...[
                  PersonPicture.determine(
                    key: Key(messageId),
                    stringKey: messageId,
                    radius: 36,
                    color: Colors.indigo,
                    profilePicture: profilePicture.value,
                    initials: Core.auth.returnNameInitials(name),
                  ),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 36),
                  )
                ],
              ] else
                ...[],

              const Padding(padding: EdgeInsets.only(left: 9)),
              // Chat bubble
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSameSenderAsInPast && chatType == ChatType.group) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 15, bottom: 4),
                      child: Text(
                        name,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                  if (type == MessageTypes.text) ...[
                    InkWell(
                      highlightColor: const Color(0x00000000),
                      focusColor: const Color(0x00000000),
                      hoverColor: const Color(0x00000000),
                      splashColor: const Color(0x00000000),
                      onTap: () => change(),
                      onLongPress: () => textMessageOptions(
                          context, messageId, chatId, text, ref),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.messageBubble,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(isSameSenderAsInPast ? 0 : 20),
                            bottomLeft: Radius.circular(
                                isSameSenderAsInFuture ||
                                        (isSameSenderAsInFuture &&
                                            isSameSenderAsInPast)
                                    ? 0
                                    : 20),
                            topRight: const Radius.circular(20),
                            bottomRight: const Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width / 1.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Linkify(
                                text: text,
                                onOpen: (link) async {
                                  if (await canLaunch(link.url)) {
                                    await launch(link.url, forceWebView: true);
                                  } else {
                                    throw 'Could not launch $link';
                                  }
                                },
                                style: TextStyle(
                                    fontSize:
                                        regexEmoji.hasMatch(text) ? 30 : 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
                                linkStyle: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                      onLongPress: () => ref.watch(repliesDebug)
                          ? imageMessageOptions(context, messageId, chatId, ref)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: bubbleRadius,
                        ),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width / 1.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: bubbleRadius,
                              child: Hero(
                                tag: documentData['link'],
                                child: CachedNetworkImage(
                                  imageUrl: documentData['link'],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              )
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
            padding:
                EdgeInsets.only(left: chatType == ChatType.private ? 20 : 60),
            height: selected.value ? 20 : 0,
            child: Row(
              children: [
                Text(
                  locales.received,
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
