import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/image_view.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/components/swipe_to.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/models/messages.dart';
import 'package:allo/logic/client/hooks.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/models/types.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void _messageOptions(
    BuildContext context,
    String messageId,
    String chatId,
    String messageText,
    WidgetRef ref,
    bool isSentByUser,
    bool isImage,
    ColorScheme colorScheme) {
  final editMessage = usePreference(ref, editMessageDebug);
  final locales = S.of(context);
  showMagicBottomSheet(
    colorScheme: colorScheme,
    context: context,
    title: locales.messageOptions,
    children: [
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
      if (editMessage.preference && isSentByUser) ...[
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
                context: context,
                chatId: chatId,
                messageId: messageId,
                colorScheme: colorScheme,
                ref: ref);
          },
        ),
      ],
    ],
  );
}

void _deleteMessage(
    {required BuildContext context,
    required String chatId,
    required String messageId,
    required ColorScheme colorScheme,
    required WidgetRef ref}) {
  final locales = S.of(context);
  showPlatformDialog(
    context: context,
    builder: (context) => AlertDialog(
      alignment: Alignment.center,
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: colorScheme.surface,
      title: Column(
        children: [
          Icon(
            Icons.delete_outlined,
            color: colorScheme.error,
          ),
          const Padding(padding: EdgeInsets.only(bottom: 10)),
          Text(
            locales.deleteMessageTitle,
            style: TextStyle(color: colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        locales.deleteMessageDescription,
        style: TextStyle(color: colorScheme.onSurface),
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.only(left: 20, right: 20),
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(colorScheme.error)),
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(
                const Duration(seconds: 1),
                () {
                  Core.chat(chatId)
                      .messages
                      .deleteMessage(messageId: messageId);
                  Core.stub.showInfoBar(
                      context: context,
                      icon: Icons.delete_outline,
                      text: locales.messageDeleted);
                },
              );
            },
            child: Text(
              locales.delete,
              style: TextStyle(color: colorScheme.onError),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              locales.cancel,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ),
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
  final ChatType type;
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
    required this.reply,
  });
  final String id;
  final String text;
  final bool isNextSenderSame;
  final bool isPreviousSenderSame;
  final bool isLast;
  final MessageType type;
  final String? image;
  final bool isRead;
  final DateTime time;
  final ReplyMessageData? reply;
}

class Bubble extends HookConsumerWidget {
  const Bubble({
    required Key key,
    required this.user,
    required this.chat,
    required this.message,
    required this.colorScheme,
    required this.modifiers,
  }) : super(key: key);
  final UserInfo user;
  final ChatInfo chat;
  final MessageInfo message;
  final ColorScheme colorScheme;
  final ValueNotifier<InputModifier?> modifiers;

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
    final replies = usePreference(ref, repliesDebug);
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

    useEffect(() {
      if (isNotCurrentUser && message.isRead == false) {
        Core.chat(chat.id).messages.markAsRead(messageId: message.id);
      }
      return;
    }, const []);

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
          SwipeTo(
            animationDuration: const Duration(milliseconds: 140),
            offsetDx: 0.2,
            leftSwipeWidget: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: theme.disabledColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.reply_rounded),
              ),
            ),
            onLeftSwipe: replies.preference == false
                ? null
                : () {
                    modifiers.value = InputModifier(
                      title: user.name,
                      body: message.text,
                      icon: Icons.reply_rounded,
                      action: ModifierAction(
                        type: ModifierType.reply,
                        replyMessageId: message.id,
                      ),
                    );
                  },
            child: InkWell(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: isNotCurrentUser
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  if (showProfilePictureConditionsMet) ...[
                    PersonPicture(
                      radius: 36,
                      profilePicture: user.profilePhoto,
                      initials: nameInitials,
                    ),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                  ] else if (chat.type == ChatType.private)
                    ...[]
                  else ...[
                    const Padding(padding: EdgeInsets.only(left: 46)),
                  ],
                  InkWell(
                    onTap: message.type == MessageType.image
                        ? () => Core.navigation.push(
                              context: context,
                              route: ImageView(message.image!,
                                  colorScheme: colorScheme),
                            )
                        : () => selected.value = !selected.value,
                    onLongPress: () => _messageOptions(
                        context,
                        message.id,
                        chat.id,
                        message.text,
                        ref,
                        !isNotCurrentUser,
                        message.type == MessageType.image,
                        colorScheme),
                    borderRadius: messageRadius,
                    child: AnimatedContainer(
                      decoration: BoxDecoration(
                        borderRadius: messageRadius,
                        color: isNotCurrentUser
                            ? colorScheme.secondaryContainer
                            : colorScheme.primary,
                      ),
                      constraints: BoxConstraints(maxWidth: screenWidth / 1.5),
                      height: null,
                      padding: message.type != MessageType.image
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
                          if (message.type == MessageType.image) {
                            return Container(
                              constraints:
                                  BoxConstraints(maxWidth: screenWidth / 1.5),
                              child: ClipRRect(
                                borderRadius: messageRadius,
                                child: CachedNetworkImage(
                                  imageUrl: message.image!,
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              constraints:
                                  BoxConstraints(maxWidth: screenWidth / 1.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: message.reply == null ? 0 : 50,
                                    child: message.reply == null
                                        ? null
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5,
                                                bottom: 5,
                                                left: 5,
                                                right: 5),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: isNotCurrentUser
                                                        ? theme.colorScheme
                                                            .onSurface
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      2,
                                                    ),
                                                  ),
                                                  height: 35,
                                                  width: 3,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    height: 40,
                                                    constraints: BoxConstraints(
                                                        maxWidth:
                                                            screenWidth / 1.8,
                                                        minWidth: 1),
                                                    width:
                                                        ((message.reply!.description
                                                                        .length
                                                                        .toDouble() >=
                                                                    message
                                                                        .reply!
                                                                        .name
                                                                        .length
                                                                        .toDouble()
                                                                ? message
                                                                    .reply!
                                                                    .description
                                                                    .length
                                                                    .toDouble()
                                                                : message.reply!
                                                                    .name.length
                                                                    .toDouble()) *
                                                            9),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          message.reply?.name ??
                                                              '',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                        ClipRect(
                                                          child: Text(
                                                            message.reply
                                                                    ?.description
                                                                    .replaceAll(
                                                                        '\n',
                                                                        ' ') ??
                                                                '',
                                                            style: const TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                  ),
                                  Linkify(
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
                                          regexEmoji.hasMatch(message.text)
                                              ? 30
                                              : 16,
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
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
