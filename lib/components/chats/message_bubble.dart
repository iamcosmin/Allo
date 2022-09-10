import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/chats/swipe_to.dart';
import 'package:allo/components/image_view.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/messages.dart';
import 'package:allo/logic/models/types.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../logic/models/chat.dart';

void _messageOptions(
  BuildContext context,
  String messageId,
  String chatId,
  String messageText,
  WidgetRef ref,
  bool isSentByUser,
  bool isImage,
  ColorScheme colorScheme,
) {
  final editMessage = useSetting(ref, editMessageDebug);
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
              icon: Icons.copy_outlined,
              text: locales.messageCopied,
            );
          },
        ),
      ],
      if (editMessage.setting && isSentByUser) ...[
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(locales.edit),
          onTap: () {
            Navigator.of(context).pop();
            Core.stub.showInfoBar(
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
              ref: ref,
            );
          },
        ),
      ],
    ],
  );
}

void _deleteMessage({
  required BuildContext context,
  required String chatId,
  required String messageId,
  required ColorScheme colorScheme,
  required WidgetRef ref,
}) {
  final locales = S.of(context);
  showDialog(
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
              backgroundColor: MaterialStateProperty.all(colorScheme.error),
            ),
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(
                const Duration(seconds: 1),
                () {
                  Core.chats
                      .chat(chatId)
                      .messages
                      .deleteMessage(messageId: messageId);
                  Core.stub.showInfoBar(
                    icon: Icons.delete_outline,
                    text: locales.messageDeleted,
                  );
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

// TODO: Declutter all and replace legacy colors with ColorScheme colors.
class Bubble extends HookConsumerWidget {
  const Bubble({
    required Key key,
    required this.chat,
    required this.message,
    required this.colorScheme,
    required this.modifiers,
    required this.isNextSenderSame,
    required this.isPreviousSenderSame,
    required this.isLast,
  }) : super(key: key);
  final Chat chat;
  final Message message;
  final ColorScheme colorScheme;
  final bool isNextSenderSame;
  final bool isPreviousSenderSame;
  final bool isLast;
  final ValueNotifier<InputModifier?> modifiers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final isNotCurrentUser = Core.auth.user.userId != message.userId;
    final nameInitials = Core.auth.returnNameInitials(message.name);
    final screenWidth = MediaQuery.of(context).size.width;
    final selected = useState(false);
    final regexEmoji = RegExp(
      r'^(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$',
    );
    final showNameConditionsMet = isNotCurrentUser &&
        Chat.getType(chat) == ChatType.group &&
        isPreviousSenderSame == false;
    final showProfilePictureConditionsMet = isNotCurrentUser &&
        Chat.getType(chat) == ChatType.group &&
        isNextSenderSame == false;
    final showReadIndicator = !isNotCurrentUser && isLast && message.read;
    // Paddings
    final betweenBubblesPadding = EdgeInsets.only(
      top: isPreviousSenderSame ? 1 : 10,
      bottom: isNextSenderSame ? 1 : 10,
      left: 10,
      right: 10,
    );
    // Radius
    final receivedMessageRadius = BorderRadius.only(
      topLeft: Radius.circular(isPreviousSenderSame ? 5 : 20),
      bottomLeft: Radius.circular(isNextSenderSame ? 5 : 20),
      topRight: const Radius.circular(20),
      bottomRight: const Radius.circular(20),
    );
    final sentMessageRadius = BorderRadius.only(
      topRight: Radius.circular(isPreviousSenderSame ? 5 : 20),
      bottomRight: Radius.circular(isNextSenderSame ? 5 : 20),
      topLeft: const Radius.circular(20),
      bottomLeft: const Radius.circular(20),
    );
    final messageRadius =
        isNotCurrentUser ? receivedMessageRadius : sentMessageRadius;
    final messageType = MessageType.fromMessage(message);
    final messageBubbleBackground = isNotCurrentUser
        ? context.colorScheme.secondaryContainer
        : context.colorScheme.primary;
    final messageBubbleForeground = isNotCurrentUser
        ? context.colorScheme.onSecondaryContainer
        : context.colorScheme.onPrimary;
    String messageBody() {
      switch (MessageType.fromMessage(message)) {
        case MessageType.text:
          return (message as TextMessage).text;
        case MessageType.image:
          return context.locale.image;
        case MessageType.unsupported:
          return context.locale.unsupportedMessage;
      }
    }

    useEffect(
      () {
        if (isNotCurrentUser && message.read == false) {
          Core.chats.chat(chat.id).messages.markAsRead(messageId: message.id);
        }
        return;
      },
      const [],
    );

    return Padding(
      padding: betweenBubblesPadding,
      child: SwipeTo(
        leftSwipeWidget: const _ReplyIcon(),
        onLeftSwipe: () {
          modifiers.value = ReplyInputModifier(
            name: message.name,
            message: messageBody(),
            id: message.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showNameConditionsMet) ...[
              Padding(
                padding: const EdgeInsets.only(left: 55, bottom: 5),
                child: Text(
                  message.name,
                  style: context.textTheme.bodySmall!.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: isNotCurrentUser
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (showProfilePictureConditionsMet) ...[
                  PersonPicture(
                    radius: 35,
                    profilePicture: Core.auth.getProfilePicture(message.userId),
                    initials: nameInitials,
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                ] else if (Chat.getType(chat) == ChatType.private)
                  ...[]
                else ...[
                  const Padding(padding: EdgeInsets.only(left: 45)),
                ],
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: screenWidth / 1.3),
                  child: InkWell(
                    onTap: () {
                      switch (messageType) {
                        case MessageType.text:
                          selected.value = !selected.value;
                          break;
                        case MessageType.image:
                          Navigation.forward(
                            ImageView(
                              (message as ImageMessage).link,
                              colorScheme: context.colorScheme,
                            ),
                          );
                          break;
                        case MessageType.unsupported:
                          break;
                      }
                    },
                    onLongPress: () => _messageOptions(
                      context,
                      message.id,
                      chat.id,
                      messageBody(),
                      ref,
                      !isNotCurrentUser,
                      messageType == MessageType.image,
                      colorScheme,
                    ),
                    borderRadius: messageRadius,
                    child: Column(
                      crossAxisAlignment: isNotCurrentUser
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          decoration: BoxDecoration(
                            borderRadius: messageRadius,
                            color: messageBubbleBackground,
                          ),
                          padding: messageType != MessageType.image
                              ? const EdgeInsets.all(9)
                              : EdgeInsets.zero,
                          key: key,
                          duration: const Duration(milliseconds: 250),
                          child: DefaultTextStyle(
                            style: TextStyle(
                              color: messageBubbleForeground,
                              fontFamily: 'Jakarta',
                              overflow: TextOverflow.ellipsis,
                              fontSize: context.textTheme.bodyMedium!.fontSize,
                            ),
                            child: Builder(
                              builder: (context) {
                                if (messageType == MessageType.image) {
                                  return Container(
                                    constraints: BoxConstraints(
                                      maxWidth: screenWidth / 1.5,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: messageRadius,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            (message as ImageMessage).link,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: message.reply == null ? 0 : 46,
                                        child: message.reply == null
                                            ? null
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 5,
                                                  bottom: 5,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            messageBubbleForeground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          2,
                                                        ),
                                                      ),
                                                      height: 32,
                                                      width: 2,
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                        right: 10,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            message.reply
                                                                    ?.name ??
                                                                '',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            message.reply
                                                                    ?.description
                                                                    .replaceAll(
                                                                  '\n',
                                                                  ' ',
                                                                ) ??
                                                                '',
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                      ),
                                      Linkify(
                                        text: messageBody(),
                                        onOpen: (link) async {
                                          final uri = Uri.parse(link.url);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri);
                                          } else {
                                            throw 'Could not launch $link';
                                          }
                                        },
                                        style: TextStyle(
                                          fontSize:
                                              regexEmoji.hasMatch(messageBody())
                                                  ? 30
                                                  : context.textTheme
                                                      .bodyMedium!.fontSize,
                                          color: messageBubbleForeground,
                                        ),
                                        linkStyle: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                          color: messageBubbleForeground,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.ease,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          height: selected.value || showReadIndicator ? 20 : 0,
                          child: Row(
                            mainAxisAlignment: isNotCurrentUser
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            children: [
                              Text(
                                !isNotCurrentUser
                                    ? (message.read
                                        ? locales.read
                                        : locales.sent)
                                    : locales.received,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(left: 3)),
                              Text(
                                DateFormat.Hm()
                                    .format(message.timestamp.toDate()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colorScheme.onSurface,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyIcon extends StatelessWidget {
  const _ReplyIcon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            Icons.reply_rounded,
            color: context.colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}
