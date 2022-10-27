import 'package:allo/components/chat/message/swipe_action.dart';
import 'package:allo/components/chat/message_input.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/photo.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/client/theme/animations.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/messages.dart';
import 'package:allo/logic/models/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../logic/models/chat.dart';
import '../../image_view.dart';
import 'background.dart';

const _kBubbleNormalRadius = Radius.circular(20);
const _kBubbleCornerRadius = Radius.circular(5);

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
  showMagicBottomSheet(
    colorScheme: colorScheme,
    context: context,
    title: context.loc.messageOptions,
    children: [
      if (!isImage) ...[
        ListTile(
          leading: const Icon(Icons.copy_outlined),
          title: Text(context.loc.copy),
          onTap: () {
            Navigator.of(context).pop();
            Clipboard.setData(ClipboardData(text: messageText));
            Core.stub.showInfoBar(
              icon: Icons.copy_outlined,
              text: context.loc.messageCopied,
            );
          },
        ),
      ],
      if (editMessage.setting && isSentByUser) ...[
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(context.loc.edit),
          onTap: () {
            Navigator.of(context).pop();
            Core.stub.showInfoBar(
              icon: Icons.info_outlined,
              text: context.loc.comingSoon,
            );
          },
        ),
      ],
      if (isSentByUser) ...[
        ListTile(
          leading: const Icon(Icons.delete_outlined),
          title: Text(context.loc.delete),
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
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        Icons.delete_outlined,
        color: colorScheme.error,
      ),
      actionsAlignment: MainAxisAlignment.center,
      title: Text(
        context.loc.deleteMessageTitle,
        style: TextStyle(color: colorScheme.onSurface),
        textAlign: TextAlign.center,
      ),
      content: Text(
        context.loc.deleteMessageDescription,
        style: TextStyle(color: colorScheme.onSurface),
      ),
      backgroundColor: colorScheme.surface,
      actions: [
        ElevatedButton(
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
                  text: context.loc.messageDeleted,
                );
              },
            );
          },
          child: Text(
            context.loc.delete,
            style: TextStyle(color: colorScheme.onError),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            context.loc.cancel,
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
      ],
    ),
  );
}

class Bubble extends HookConsumerWidget {
  const Bubble({
    required Key key,
    required this.chat,
    required this.message,
    required this.modifiers,
    required this.isNextSenderSame,
    required this.isPreviousSenderSame,
    required this.isLast,
  }) : super(key: key);
  final Chat chat;
  final Message message;
  final bool isNextSenderSame;
  final bool isPreviousSenderSame;
  final bool isLast;
  final ValueNotifier<InputModifier?> modifiers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      topLeft:
          isPreviousSenderSame ? _kBubbleCornerRadius : _kBubbleNormalRadius,
      bottomLeft:
          isNextSenderSame ? _kBubbleCornerRadius : _kBubbleNormalRadius,
      topRight: _kBubbleNormalRadius,
      bottomRight: _kBubbleNormalRadius,
    );
    final sentMessageRadius = BorderRadius.only(
      topRight:
          isPreviousSenderSame ? _kBubbleCornerRadius : _kBubbleNormalRadius,
      bottomRight:
          isNextSenderSame ? _kBubbleCornerRadius : _kBubbleNormalRadius,
      topLeft: _kBubbleNormalRadius,
      bottomLeft: _kBubbleNormalRadius,
    );
    final messageRadius =
        isNotCurrentUser ? receivedMessageRadius : sentMessageRadius;
    final bubbleColors = [
      if (isNotCurrentUser) ...[
        context.colorScheme.secondaryContainer
      ] else ...[
        context.colorScheme.primary,
        context.colorScheme.tertiary,
      ]
    ];
    final messageBubbleForeground = isNotCurrentUser
        ? context.colorScheme.onSecondaryContainer
        : context.colorScheme.onPrimary;

    String messageBody() {
      switch (MessageType.fromMessage(message)) {
        case MessageType.text:
          return (message as TextMessage).text;
        case MessageType.image:
          return context.loc.image;
        case MessageType.unsupported:
          return context.loc.unsupportedMessage;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isNotCurrentUser
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: isNotCurrentUser
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (showProfilePictureConditionsMet) ...[
                PersonPicture(
                  radius: 35,
                  profilePicture: Core.auth.getProfilePicture(message.userId),
                  initials: nameInitials,
                ),
                const Padding(padding: EdgeInsets.only(left: 10)),
              ] else if (isNotCurrentUser && chat is GroupChat) ...[
                const Padding(padding: EdgeInsets.only(left: 45)),
              ],
              Expanded(
                child: SwipeAction(
                  alignment: isNotCurrentUser
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  action: const Icon(Icons.reply),
                  callback: () {
                    modifiers.value = ReplyInputModifier(
                      name: message.name,
                      message: messageBody(),
                      id: message.id,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showNameConditionsMet) ...[_Name(message.name)],
                      ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: screenWidth / 1.5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: isNotCurrentUser
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            ClipRRect(
                              borderRadius: messageRadius,
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  onTap: () {
                                    switch (message.runtimeType) {
                                      case TextMessage:
                                        selected.value = !selected.value;
                                        break;
                                      case ImageMessage:
                                        Navigation.forward(
                                          ImageView(
                                            (message as ImageMessage).link,
                                            colorScheme: context.colorScheme,
                                          ),
                                        );
                                        break;
                                      case UnsupportedMessage:
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
                                    message is ImageMessage,
                                    context.colorScheme,
                                  ),
                                  child: BubbleBackground(
                                    colors: bubbleColors,
                                    child: AnimatedContainer(
                                      padding: message is! ImageMessage
                                          ? const EdgeInsets.all(9)
                                          : EdgeInsets.zero,
                                      key: key,
                                      duration:
                                          const Duration(milliseconds: 250),
                                      child: DefaultTextStyle(
                                        style: TextStyle(
                                          color: messageBubbleForeground,
                                          fontFamily: 'Jakarta',
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: context
                                              .textTheme.bodyMedium!.fontSize,
                                        ),
                                        child: Builder(
                                          builder: (context) {
                                            if (message is ImageMessage) {
                                              return Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: screenWidth / 1.5,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: messageRadius,
                                                  child: Photo(
                                                    url: (message
                                                            as ImageMessage)
                                                        .link,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height:
                                                        message.reply == null
                                                            ? 0
                                                            : 46,
                                                    child: message.reply == null
                                                        ? null
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              top: 5,
                                                              bottom: 5,
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
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
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
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
                                                                        message.reply?.name ??
                                                                            '',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        message.reply?.description.replaceAll(
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
                                                      final uri =
                                                          Uri.parse(link.url);
                                                      if (await canLaunchUrl(
                                                        uri,
                                                      )) {
                                                        await launchUrl(
                                                          uri,
                                                          mode: LaunchMode
                                                              .externalApplication,
                                                        );
                                                      } else {
                                                        throw 'Could not launch $link';
                                                      }
                                                    },
                                                    style: TextStyle(
                                                      fontSize:
                                                          regexEmoji.hasMatch(
                                                        messageBody(),
                                                      )
                                                              ? 30
                                                              : context
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .fontSize,
                                                      color:
                                                          messageBubbleForeground,
                                                    ),
                                                    linkStyle: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          messageBubbleForeground,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              curve: Motion.animation.emphasized,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              height:
                                  selected.value || showReadIndicator ? 20 : 0,
                              child: Row(
                                mainAxisAlignment: isNotCurrentUser
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                children: [
                                  Text(
                                    !isNotCurrentUser
                                        ? (message.read
                                            ? context.loc.read
                                            : context.loc.sent)
                                        : context.loc.received,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 3),
                                  ),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Name extends StatelessWidget {
  const _Name(this.name);

  final String name;

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
      child: Text(
        name,
        style: context.textTheme.bodySmall!.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
