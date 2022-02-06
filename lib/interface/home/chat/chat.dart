import 'package:allo/components/chats/bubbles/message_bubble.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/chat/chat_details.dart';
import 'package:allo/interface/home/settings/debug/typingbubble.dart';
import 'package:allo/logic/chat/messages.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/theme.dart';
import 'package:allo/logic/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: must_be_immutable
class ChatScreen extends HookConsumerWidget {
  final ChatType chatType;
  final String title;
  final String chatId;
  String? profilepic;
  ChatScreen(
      {required this.title,
      required this.chatId,
      required this.chatType,
      this.profilepic,
      Key? key})
      : super(key: key);
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typing = useState(false);
    final theme = useState<ColorScheme>(
      ColorScheme.fromSeed(
          seedColor: Colors.blue, brightness: Theme.of(context).brightness),
    );
    final colors = ref.watch(colorsProvider);
    final messages = useState(<Message>[]);
    final controller = useScrollController();
    final inputModifiers = useState<InputModifier?>(null);
    final locales = S.of(context);

    useEffect(() {
      if (!kIsWeb) {
        FirebaseMessaging.instance.subscribeToTopic(chatId);
      }
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .snapshots()
          .listen(
        (event) {
          typing.value = event.data()!['typing'] ?? false;
          var dbThemeId = event.data()!['theme'] ?? 'blue';
          var themeIndex = themesId(context).indexOf(dbThemeId);
          theme.value = ColorScheme.fromSeed(
              seedColor: themes(context)[themeIndex]['color'],
              primary: themes(context)[themeIndex]['color'],
              brightness: Theme.of(context).brightness);
        },
      );
      Core.chat(chatId)
          .streamChatMessages(messages: messages, listKey: listKey);
      return;
    }, const []);
    return Scaffold(
      backgroundColor: theme.value.background,
      appBar: AppBar(
        backgroundColor: theme.value.surface,
        elevation: 2,
        iconTheme: IconThemeData(color: theme.value.onSurface),
        toolbarHeight: 100,
        leading: Container(
          padding: const EdgeInsets.only(left: 10, top: 0),
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(
            left: 20,
            bottom: 10,
          ),
          title: InkWell(
            onTap: () => Core.navigation.push(
                context: context,
                route: ChatDetails(
                  name: title,
                  id: chatId,
                  profilepic: profilepic,
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.only(right: 10),
                      child: PersonPicture.determine(
                        profilePicture: profilepic,
                        radius: 37,
                        initials: Core.auth.returnNameInitials(title),
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyText1!.color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    flex: 10,
                    child: AnimatedList(
                      padding: const EdgeInsets.only(top: 10),
                      key: listKey,
                      reverse: true,
                      controller: controller,
                      itemBuilder: (context, i, animation) {
                        final currentMessage = messages.value[i];
                        final senderUid = currentMessage.userId;
                        final Map pastData, nextData;
                        if (i == 0) {
                          nextData = {'senderUID': 'null'};
                        } else {
                          nextData = messages.value[i - 1].data;
                        }
                        if (i == messages.value.length - 1) {
                          pastData = {'senderUID': 'null'};
                        } else {
                          pastData = messages.value[i + 1].data;
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

                        final isNextSenderSame = nextUID == senderUid;
                        final isPrevSenderSame = pastUID == senderUid;
                        MessageInfo? messageInfo() {
                          final messageValue = messages.value[i];
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
                                    messageValue
                                        .timestamp.millisecondsSinceEpoch),
                                type: MessageTypes.text);
                          } else if (messageValue is ImageMessage) {
                            return MessageInfo(
                                id: messageValue.id,
                                text: locales.image,
                                isNextSenderSame: isNextSenderSame,
                                isPreviousSenderSame: isPrevSenderSame,
                                type: MessageTypes.image,
                                image: messageValue.link,
                                isRead: messageValue.read,
                                time: DateTime.fromMillisecondsSinceEpoch(
                                    messageValue
                                        .timestamp.millisecondsSinceEpoch),
                                isLast: nextUID == 'null',
                                reply: messageValue.reply);
                          } else {
                            return null;
                          }
                        }

                        if (i == messages.value.length - 1) {
                          return Column(
                            children: [
                              /// TODO: MODIFY THIS SO IT COMPLIES WITH THE NEW [Message] MODEL.
                              // ElevatedButton(
                              //   style: ButtonStyle(
                              //     shape: MaterialStateProperty.all(
                              //         RoundedRectangleBorder(
                              //             borderRadius:
                              //                 BorderRadius.circular(100))),
                              //     backgroundColor:
                              //         MaterialStateProperty.all(theme.value),
                              //   ),
                              //   onPressed: () {
                              //     isLoadingPrevMessages.value = true;
                              //     FirebaseFirestore.instance
                              //         .collection('chats')
                              //         .doc(chatId)
                              //         .collection('messages')
                              //         .orderBy('time', descending: true)
                              //         .startAfterDocument(documentSnapshot)
                              //         .limit(20)
                              //         .get()
                              //         .then((value) {
                              //       for (var doc in value.docs) {
                              //         messages.value.add(doc);
                              //         listKey.currentState?.insertItem(
                              //             messages.value.length - 1,
                              //             duration: const Duration(seconds: 0));
                              //       }
                              //     });
                              //     isLoadingPrevMessages.value = false;
                              //   },
                              //   child: isLoadingPrevMessages.value == false
                              //       ? Text(locales.showPastMessages)
                              //       : const CircularProgressIndicator(),
                              // ),
                              const Padding(padding: EdgeInsets.only(top: 20)),

                              SizeTransition(
                                axisAlignment: -1,
                                sizeFactor: CurvedAnimation(
                                    curve: Curves.easeOutQuint,
                                    parent: animation),
                                child: Bubble(
                                  colorScheme: theme.value,
                                  chat: ChatInfo(id: chatId, type: chatType),
                                  message: messageInfo()!,
                                  user: UserInfo(
                                      name: messages.value[i].name,
                                      userId: messages.value[i].userId,
                                      profilePhoto:
                                          'gs://allo-ms.appspot.com/profilePictures/${messages.value[i].userId}.png'),
                                  key: Key(messages.value[i].id),
                                  modifiers: inputModifiers,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return SizeTransition(
                            axisAlignment: -1,
                            sizeFactor: CurvedAnimation(
                                curve: Curves.easeInOutCirc, parent: animation),
                            child: Bubble(
                              colorScheme: theme.value,
                              chat: ChatInfo(id: chatId, type: chatType),
                              message: messageInfo()!,
                              user: UserInfo(
                                  name: messages.value[i].name,
                                  userId: messages.value[i].userId,
                                  profilePhoto:
                                      'gs://allo-ms.appspot.com/profilePictures/${messages.value[i].userId}.png'),
                              key: Key(messages.value[i].id),
                              modifiers: inputModifiers,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TypingIndicator(
                      bubbleColor: colors.messageBubble,
                      flashingCircleBrightColor:
                          colors.flashingCircleBrightColor,
                      flashingCircleDarkColor: colors.flashingCircleDarkColor,
                      showIndicator: false,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 0,
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.bottomCenter,
                child: MessageInput(
                  modifier: inputModifiers,
                  chatId: chatId,
                  chatName: title,
                  chatType: chatType,
                  theme: theme.value,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
