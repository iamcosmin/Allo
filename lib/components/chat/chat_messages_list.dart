import 'package:allo/components/chat/message/bubble.dart';
import 'package:allo/components/chat/message_input.dart';
import 'package:allo/components/info.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/messages.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// class _ChatListProviderArguments {
//   _ChatListProviderArguments({
//     required this.chatId,
//     required this.listKey,
//     required this.context,
//   });
//   final String chatId;
//   final GlobalKey<AnimatedListState> listKey;
//   final BuildContext context;
// }

// final chatListProvider = StateNotifierProvider.autoDispose
//     .family<_ChatList, AsyncValue<List<Message>?>, _ChatListProviderArguments>(
//   (ref, args) {
//     return _ChatList(
//       chatId: args.chatId,
//       context: args.context,
//       listKey: args.listKey,
//     )..init();
//   },
// );

// class _ChatList extends StateNotifier<AsyncValue<List<Message>?>> {
//   _ChatList({
//     required this.chatId,
//     required this.listKey,
//     required this.context,
//   }) : super(const AsyncValue.loading());
//   final String chatId;
//   final GlobalKey<AnimatedListState> listKey;
//   final BuildContext context;

//   final List<Message> messages = [];

//   void init() {
//     fetch();
//   }

//   void fetch() {
//     state = const AsyncValue.loading();
//     try {
//       Core.chats.chat(chatId)
//           .streamChatMessages(listKey: listKey, context: context, limit: 20)
//           .listen((event) {
//         print('FIRST FETCH');
//         messages.addAll(event);
//         state = AsyncValue.data(messages);
//       });
//     } catch (e) {
//       state = AsyncValue.error(e);
//     }
//   }

//   void fetchMore() {
//     try {
//       Core.chats.chat(chatId)
//           .streamChatMessages(
//         listKey: listKey,
//         context: context,
//         limit: 20,
//         lastIndex: state.asData?.value?.length,
//         startAfter: state.asData?.value?.last.documentSnapshot,
//       )
//           .listen((event) {
//         print('SECOND FETCH!');
//         messages.addAll(event);
//         state = AsyncValue.data(messages);
//       });
//     } catch (e) {
//       state = AsyncValue.error(e);
//     }
//   }
// }

final animatedListKeyProvider =
    StateProvider.autoDispose<GlobalKey<AnimatedListState>>((ref) {
  return GlobalKey<AnimatedListState>();
});

class ChatMessagesList extends HookConsumerWidget {
  const ChatMessagesList({
    required this.chat,
    required this.inputModifiers,
    super.key,
  });
  final Chat chat;
  final ValueNotifier<InputModifier?> inputModifiers;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFab = useState(false);
    final locales = context.loc;
    final streamList = useState<List<Message>?>(null);
    final error = useState<Object?>(null);
    final chatId = chat.id;
    useEffect(
      () {
        Core.chats
            .chat(chatId)
            .streamChatMessages(limit: 30, context: context, ref: ref)
            .listen((event) {
          streamList.value = event;
        }).onError((e) {
          error.value = e;
        });
        return;
      },
      const [],
    );

    if (streamList.value != null && streamList.value!.isNotEmpty) {
      final data = streamList.value!;
      return NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            if (notification.metrics.pixels > 100 && showFab.value == false) {
              showFab.value = true;
            } else if (notification.metrics.pixels < 10 &&
                showFab.value == true) {
              showFab.value = false;
            }
          }
          return true;
        },
        child: Scaffold(
          floatingActionButton: showFab.value
              ? FloatingActionButton.small(
                  onPressed: () {
                    PrimaryScrollController.of(context)?.animateTo(
                      0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.fastOutSlowIn,
                    );
                  },
                  child: const Icon(Icons.arrow_downward_rounded),
                )
              : null,
          body: AnimatedList(
            padding: const EdgeInsets.only(top: 10),
            key: ref.watch(animatedListKeyProvider),
            reverse: true,
            controller: PrimaryScrollController.of(context),
            initialItemCount: data.length,
            itemBuilder: (context, i, animation) {
              final message = data[i];
              var isPreviousSenderSame = false;
              var isNextSenderSame = false;
              var isLast = false;

              if (i == 0) {
                isLast = true;
              }
              if (i > 0) {
                final nextMessage = data[i - 1];
                isNextSenderSame = nextMessage.userId == message.userId;
              }
              if (i < data.length - 1) {
                final previousMessage = data[i + 1];
                isPreviousSenderSame = previousMessage.userId == message.userId;
              }

              return Column(
                children: [
                  if (i == data.length - 1 &&
                      streamList.value != null &&
                      streamList.value!.length >= 30) ...[
                    const Padding(padding: EdgeInsets.only(top: 20)),
                    ElevatedButton(
                      onPressed: () {
                        Core.chats
                            .chat(chatId)
                            .streamChatMessages(
                              ref: ref,
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
                      curve: Curves.fastOutSlowIn,
                      parent: animation,
                    ),
                    child: Bubble(
                      chat: chat,
                      isNextSenderSame: isNextSenderSame,
                      isPreviousSenderSame: isPreviousSenderSame,
                      isLast: isLast,
                      message: message,
                      key: Key(message.id),
                      modifiers: inputModifiers,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    } else if (streamList.value != null && streamList.value!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: InfoWidget(
          text: 'No messages here.',
        ),
      );
    } else if (error.value != null) {
      final errorMessage =
          '${locales.anErrorOccurred}\n${(error.value is FirebaseException) ? 'Code: ${(error.value! as FirebaseException).code}'
              '\n'
              'Element: ${(error.value! as FirebaseException).plugin}'
              '\n\n'
              '${(error.value! as FirebaseException).message}' : error.value.toString()}';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            errorMessage,
          ),
        ),
      );
    } else if (streamList.value == null) {
      return const Center(
        child: ProgressRing(),
      );
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
