import 'package:allo/components/chats/bubbles/message_bubble.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/chat/chat_details.dart';
import 'package:allo/logic/chat/messages.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:allo/logic/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../logic/themes.dart';

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
    final scheme = useState<ColorScheme>(
      ColorScheme.fromSeed(
          seedColor: Colors.blue, brightness: Theme.of(context).brightness),
    );
    final controller = useScrollController();
    final inputModifiers = useState<InputModifier?>(null);
    final locales = S.of(context);
    final streamList = useState<List<Message>?>(null);
    final brightness = Theme.of(context).brightness;
    useEffect(() {
      Core.chat(chatId)
          .streamChatMessages(listKey: listKey, limit: 30)
          .listen((event) {
        streamList.value = event;
      });
      return;
    }, const []);
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
          scheme.value = ColorScheme.fromSeed(
              seedColor: themes(context)[themeIndex]['color'],
              primary: themes(context)[themeIndex]['color'],
              brightness: Theme.of(context).brightness);
        },
      );
      return;
    }, const []);
    return Theme(
      data: theme(brightness, ref, context, colorScheme: scheme.value),
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          toolbarHeight: 60,
          actions: [
            Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(10),
              child: PersonPicture.determine(
                profilePicture: profilepic,
                radius: 37,
                initials: Core.auth.returnNameInitials(title),
              ),
            ),
          ],
          title: InkWell(
            onTap: () => Core.navigation.push(
                context: context,
                route: ChatDetails(
                  name: title,
                  id: chatId,
                  profilepic: profilepic,
                )),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
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
                      child: Builder(
                        builder: (context) {
                          if (streamList.value != null) {
                            final data = streamList.value!;
                            return AnimatedList(
                              padding: const EdgeInsets.only(top: 10),
                              key: listKey,
                              reverse: true,
                              initialItemCount: data.length,
                              controller: controller,
                              itemBuilder: (context, i, animation) {
                                final currentMessage = data[i];
                                final senderUid = currentMessage.userId;
                                final Map pastData, nextData;
                                if (i == 0) {
                                  nextData = {'senderUID': 'null'};
                                } else {
                                  nextData = data[i - 1].documentSnapshot.data()
                                      as Map;
                                }
                                if (i == data.length - 1) {
                                  pastData = {'senderUID': 'null'};
                                } else {
                                  pastData = data[i + 1].documentSnapshot.data()
                                      as Map;
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
                                        time:
                                            DateTime.fromMillisecondsSinceEpoch(
                                                messageValue.timestamp
                                                    .millisecondsSinceEpoch),
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
                                        time:
                                            DateTime.fromMillisecondsSinceEpoch(
                                                messageValue.timestamp
                                                    .millisecondsSinceEpoch),
                                        isLast: nextUID == 'null',
                                        reply: messageValue.reply);
                                  } else {
                                    return null;
                                  }
                                }

                                return Column(
                                  children: [
                                    if (i == data.length - 1) ...[
                                      const Padding(
                                          padding: EdgeInsets.only(top: 20)),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100))),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  scheme.value.primary),
                                        ),
                                        onPressed: () {
                                          Core.chat(chatId)
                                              .streamChatMessages(
                                                  listKey: listKey,
                                                  limit: 20,
                                                  lastIndex: data.length - 1,
                                                  startAfter: data
                                                      .last.documentSnapshot)
                                              .listen((event) {
                                            streamList.value!.addAll(event);
                                          });
                                        },
                                        child: Text(
                                          locales.showPastMessages,
                                          style: TextStyle(
                                              color: scheme.value.onPrimary),
                                        ),
                                      ),
                                    ],
                                    SizeTransition(
                                      axisAlignment: -1,
                                      sizeFactor: CurvedAnimation(
                                          curve: Curves.easeInOutCirc,
                                          parent: animation),
                                      child: Bubble(
                                        colorScheme:
                                            Theme.of(context).colorScheme,
                                        chat: ChatInfo(
                                            id: chatId, type: chatType),
                                        message: messageInfo()!,
                                        user: UserInfo(
                                            name: data[i].name,
                                            userId: data[i].userId,
                                            profilePhoto:
                                                'gs://allo-ms.appspot.com/profilePictures/${data[i].userId}.png'),
                                        key: Key(data[i].id),
                                        modifiers: inputModifiers,
                                      ),
                                    ),
                                  ],
                                );
                              },
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
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: Center(
                                child: Text(
                                  locales.anErrorOccurred,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
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
                    theme: scheme.value,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
