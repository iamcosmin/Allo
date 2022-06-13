import 'package:allo/components/chats/bubbles/message_bubble.dart';
import 'package:allo/components/chats/message_input.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/messages.dart';
import 'package:allo/logic/models/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatMessagesList extends HookConsumerWidget {
  const ChatMessagesList({
    required this.chatId,
    required this.chatType,
    required this.inputModifiers,
    super.key,
  });
  final String chatId;
  final ChatType chatType;
  final ValueNotifier<InputModifier?> inputModifiers;
  static GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useScrollController();
    final locales = context.locale;
    final streamList = useState<List<Message>?>(null);
    useEffect(
      () {
        Core.chat(chatId)
            .streamChatMessages(listKey: listKey, limit: 30, context: context)
            .listen((event) {
          streamList.value = event;
        });
        return;
      },
      const [],
    );

    if (streamList.value != null) {
      final data = streamList.value!;
      return SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: AnimatedList(
            padding: const EdgeInsets.only(top: 10),
            key: listKey,
            reverse: true,
            shrinkWrap: true,
            initialItemCount: data.length,
            controller: controller,
            itemBuilder: (context, i, animation) {
              final currentMessage = data[i];
              final senderUid = currentMessage.userId;
              final Map pastData, nextData;
              if (i == 0) {
                nextData = {'senderUID': 'null'};
              } else {
                nextData = data[i - 1].documentSnapshot.data() as Map? ??
                    (throw Exception('nextData is null.'));
              }
              if (i == data.length - 1) {
                pastData = {'senderUID': 'null'};
              } else {
                pastData = data[i + 1].documentSnapshot.data() as Map? ??
                    (throw Exception('pastData is null'));
              }
              // Above, pastData should have been i-1 and nextData i+1.
              // But, as the list needs to be in reverse order, we need
              // to consider this workaround.
              final pastUID = pastData.containsKey('uid')
                  ? pastData['uid']
                  : pastData.containsKey('senderUID')
                      ? pastData['senderUID']
                      : 'null';
              final nextUID = nextData.containsKey('uid')
                  ? nextData['uid']
                  : nextData.containsKey('senderUID')
                      ? nextData['senderUID']
                      : 'null';

              // if senderUid is null, return exception

              final isNextSenderSame = nextUID == senderUid;
              final isPrevSenderSame = pastUID == senderUid;

              MessageInfo? messageInfo() {
                final messageValue = data[i];
                if (messageValue is TextMessage) {
                  return MessageInfo(
                    id: messageValue.id,
                    image: null,
                    isLast: nextUID == 'null',
                    isNextSenderSame: isNextSenderSame,
                    isPreviousSenderSame: isPrevSenderSame,
                    isRead: messageValue.read,
                    reply: messageValue.reply,
                    text: messageValue.text,
                    time: DateTime.fromMillisecondsSinceEpoch(
                      messageValue.timestamp.millisecondsSinceEpoch,
                    ),
                    type: MessageType.text,
                  );
                } else if (messageValue is ImageMessage) {
                  return MessageInfo(
                    id: messageValue.id,
                    text: locales.image,
                    isNextSenderSame: isNextSenderSame,
                    isPreviousSenderSame: isPrevSenderSame,
                    type: MessageType.image,
                    image: messageValue.link,
                    isRead: messageValue.read,
                    time: DateTime.fromMillisecondsSinceEpoch(
                      messageValue.timestamp.millisecondsSinceEpoch,
                    ),
                    isLast: nextUID == 'null',
                    reply: messageValue.reply,
                  );
                } else if (messageValue is UnsupportedMessage) {
                  return MessageInfo(
                    id: messageValue.id,
                    text: context.locale.unsupportedMessage,
                    isNextSenderSame: isNextSenderSame,
                    isPreviousSenderSame: isPrevSenderSame,
                    type: MessageType.unsupported,
                    image: null,
                    isRead: messageValue.read,
                    time: DateTime.fromMillisecondsSinceEpoch(
                      messageValue.timestamp.millisecondsSinceEpoch,
                    ),
                    isLast: nextUID == 'null',
                    reply: null,
                  );
                } else {
                  return null;
                }
              }

              return Column(
                children: [
                  if (i == data.length - 1) ...[
                    const Padding(padding: EdgeInsets.only(top: 20)),
                    ElevatedButton(
                      onPressed: () {
                        Core.chat(chatId)
                            .streamChatMessages(
                          listKey: listKey,
                          limit: 20,
                          context: context,
                          lastIndex: data.length - 1,
                          startAfter: data.last.documentSnapshot,
                        )
                            .listen((event) {
                          streamList.value!.addAll(event);
                        });
                      },
                      child: Text(
                        locales.showPastMessages,
                      ),
                    ),
                  ],
                  SizeTransition(
                    axisAlignment: -1,
                    sizeFactor: CurvedAnimation(
                      curve: Curves.easeInOutCirc,
                      parent: animation,
                    ),
                    child: Bubble(
                      colorScheme: Theme.of(context).colorScheme,
                      chat: ChatInfo(id: chatId, type: chatType),
                      message: messageInfo()!,
                      user: UserInfo(
                        name: data[i].name,
                        userId: data[i].userId,
                        profilePhoto:
                            'gs://allo-ms.appspot.com/profilePictures/${data[i].userId}.png',
                      ),
                      key: Key(data[i].id),
                      modifiers: inputModifiers,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    } else if (streamList.value == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
      // } else if (snapshot.hasError) {
      //   final errorMessage = locales.anErrorOccurred +
      //       '\n' +
      //       ((snapshot.error is FirebaseException)
      //           ? 'Code: ${(snapshot.error as FirebaseException).code}'
      //               '\n'
      //               'Element: ${(snapshot.error as FirebaseException).plugin}'
      //               '\n\n'
      //               '${(snapshot.error as FirebaseException).message}'
      //           : snapshot.error.toString());
      //   return Padding(
      //     padding: const EdgeInsets.only(left: 30, right: 30),
      //     child: Center(
      //       child: SelectableText(
      //         errorMessage,
      //       ),
      //     ),
      //   );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Center(
          child: Text(
            locales.anErrorOccurred,
          ),
        ),
      );
    }
  }
}
