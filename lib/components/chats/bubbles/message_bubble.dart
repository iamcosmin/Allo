import 'package:allo/components/image_view.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:allo/logic/types.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void _messageOptions(BuildContext context, String messageId, String chatId,
    String messageText, WidgetRef ref, bool isSentByUser, bool isImage) {
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
              icon: Icons.info_outline,
              text: locales.comingSoon,
            );
          },
        ),
      ],
      if (!isImage) ...[
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
      if (editMessage && isSentByUser) ...[
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
      if (isSentByUser) ...[
        ListTile(
          leading: const Icon(Icons.delete_outlined),
          title: Text(locales.delete),
          onTap: () {
            Navigator.of(context).pop();
            _deleteMessage(
                context: context, chatId: chatId, messageId: messageId);
          },
        ),
      ],
    ],
  );
}

void _deleteMessage(
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

class UserInfo {
  const UserInfo({required this.name, required this.userId, this.profilePhoto});
  final String name;
  final String userId;
  final String? profilePhoto;
}

class ChatInfo {
  const ChatInfo({required this.type, required this.id});
  final String type;
  final String id;
}

class MessageInfo {
  const MessageInfo({
    required this.id,
    required this.text,
    required this.isNextSenderSame,
    required this.isPreviousSenderSame,
    required this.type,
    required this.image,
    required this.isRead,
    required this.time,
    required this.isLast,
  });
  final String id;
  final String text;
  final bool isNextSenderSame;
  final bool isPreviousSenderSame;
  final bool isLast;
  final String type;
  final String? image;
  final bool isRead;
  final DateTime time;
}

class Bubble extends HookConsumerWidget {
  const Bubble({
    Key? key,
    required this.user,
    required this.chat,
    required this.message,
    required this.color,
  }) : super(key: key);
  final UserInfo user;
  final ChatInfo chat;
  final MessageInfo message;
  final Color color;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final isNotCurrentUser = Core.auth.user.uid != user.userId;
    final nameInitials = Core.auth.returnNameInitials(user.name);
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final selected = useState(false);
    final regexEmoji = RegExp(
        r'^(\u00a9|\u00ae|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$');
    final showNameConditionsMet = isNotCurrentUser &&
        chat.type == ChatType.group &&
        message.isPreviousSenderSame == false;
    final showProfilePictureConditionsMet = isNotCurrentUser &&
        chat.type == ChatType.group &&
        message.isNextSenderSame == false;
    final showReadIndicator =
        !isNotCurrentUser && message.isLast && message.isRead;
    // Paddings
    final betweenBubblesPadding = EdgeInsets.only(
        top: message.isPreviousSenderSame ? 1 : 10,
        bottom: message.isNextSenderSame ? 1 : 10,
        left: 10,
        right: 10);
    // Radius
    final receivedMessageRadius = BorderRadius.only(
      topLeft: Radius.circular(message.isPreviousSenderSame ? 5 : 20),
      bottomLeft: Radius.circular(message.isNextSenderSame ? 5 : 20),
      topRight: const Radius.circular(20),
      bottomRight: const Radius.circular(20),
    );
    final sentMessageRadius = BorderRadius.only(
      topRight: Radius.circular(message.isPreviousSenderSame ? 5 : 20),
      bottomRight: Radius.circular(message.isNextSenderSame ? 5 : 20),
      topLeft: const Radius.circular(20),
      bottomLeft: const Radius.circular(20),
    );
    final messageRadius =
        isNotCurrentUser ? receivedMessageRadius : sentMessageRadius;

    return Padding(
      padding: betweenBubblesPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showNameConditionsMet) ...[
            Padding(
              padding: const EdgeInsets.only(left: 55, bottom: 2),
              child: Text(
                user.name,
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
            ),
          ],
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: isNotCurrentUser
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (showProfilePictureConditionsMet) ...[
                PersonPicture.determine(
                  radius: 36,
                  profilePicture: user.profilePhoto,
                  initials: nameInitials,
                  color: color,
                ),
                const Padding(padding: EdgeInsets.only(left: 10)),
              ] else ...[
                const Padding(padding: EdgeInsets.only(left: 46)),
              ],
              InkWell(
                onTap: message.type == MessageTypes.image
                    ? () => Core.navigation.push(
                          context: context,
                          route: ImageView(
                            message.image!,
                          ),
                        )
                    : () => selected.value = !selected.value,
                onLongPress: () => _messageOptions(
                    context,
                    message.id,
                    chat.id,
                    message.text,
                    ref,
                    !isNotCurrentUser,
                    message.type == MessageTypes.image),
                customBorder:
                    RoundedRectangleBorder(borderRadius: messageRadius),
                child: AnimatedContainer(
                  decoration: BoxDecoration(
                    borderRadius: messageRadius,
                    color: isNotCurrentUser ? theme.dividerColor : color,
                  ),
                  constraints: BoxConstraints(maxWidth: screenWidth / 1.5),
                  padding: message.type != MessageTypes.image
                      ? const EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          left: 10,
                          right: 10,
                        )
                      : EdgeInsets.zero,
                  key: key,
                  duration: const Duration(milliseconds: 250),
                  child: Builder(
                    builder: (context) {
                      if (message.type == MessageTypes.image) {
                        return ClipRRect(
                          borderRadius: messageRadius,
                          child: CachedNetworkImage(
                            imageUrl: message.image!,
                          ),
                        );
                      } else {
                        return Linkify(
                          text: message.text,
                          onOpen: (link) async {
                            if (await canLaunch(link.url)) {
                              await launch(link.url);
                            } else {
                              throw 'Could not launch $link';
                            }
                          },
                          style: TextStyle(
                            fontSize:
                                regexEmoji.hasMatch(message.text) ? 30 : 16,
                            color: isNotCurrentUser
                                ? theme.colorScheme.onSurface
                                : Colors.white,
                          ),
                          linkStyle: TextStyle(
                            decoration: TextDecoration.underline,
                            color: isNotCurrentUser
                                ? theme.colorScheme.onSurface
                                : Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.ease,
            padding: const EdgeInsets.only(right: 5, left: 55),
            height: selected.value || showReadIndicator ? 20 : 0,
            child: Row(
              mainAxisAlignment: isNotCurrentUser
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Text(
                  !isNotCurrentUser
                      ? (message.isRead ? locales.read : locales.sent)
                      : locales.received,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
                const Padding(padding: EdgeInsets.only(left: 3)),
                Text(
                  DateFormat.Hm().format(message.time),
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
