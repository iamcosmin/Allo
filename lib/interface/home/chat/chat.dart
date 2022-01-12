import 'package:allo/interface/home/chat/chat_details.dart';
import 'package:allo/interface/home/settings/debug/typingbubble.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/chats/bubbles/message_bubble.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: must_be_immutable
class Chat extends HookConsumerWidget {
  final String chatType;
  final String title;
  final String chatId;
  String? profilepic;
  Chat(
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
    final theme = useState<Color>(Colors.blue);
    final colors = ref.watch(colorsProvider);
    final messages = useState(<DocumentSnapshot>[]);
    final controller = useScrollController();
    final isLoadingPrevMessages = useState(false);

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
          var themeIndex = themesId().indexOf(dbThemeId);
          theme.value = themes[themeIndex]['color'];
        },
      );
      Core.chat(chatId)
          .streamChatMessages(messages: messages, listKey: listKey);
    }, const []);
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          leading: Container(
            padding: const EdgeInsets.only(left: 10, top: 0),
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(FluentIcons.arrow_left_16_regular),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 10),
            title: GestureDetector(
              onTap: () => Core.navigation.push(
                  context: context,
                  route: ChatDetails(
                    name: title,
                    id: chatId,
                    profilepic: profilepic,
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.only(right: 10),
                    child: PersonPicture.determine(
                      profilePicture: profilepic,
                      radius: 37,
                      initials: Core.auth.returnNameInitials(title),
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w600),
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
                          final Map pastData, nextData;
                          if (i == 0) {
                            nextData = {'senderUID': 'null'};
                          } else {
                            nextData = messages.value[i - 1].data() as Map;
                          }
                          if (i == messages.value.length - 1) {
                            pastData = {'senderUID': 'null'};
                          } else {
                            pastData = messages.value[i + 1].data() as Map;
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
                          if (i == messages.value.length - 1) {
                            return Column(
                              children: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              isLoadingPrevMessages.value ==
                                                      false
                                                  ? Colors.blue
                                                  : Colors.black)),
                                  onPressed: () {
                                    isLoadingPrevMessages.value = true;
                                    FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc(chatId)
                                        .collection('messages')
                                        .orderBy('time', descending: true)
                                        .startAfterDocument(messages
                                            .value[messages.value.length - 1])
                                        .limit(20)
                                        .get()
                                        .then((value) {
                                      for (var doc in value.docs) {
                                        messages.value.add(doc);
                                        listKey.currentState?.insertItem(
                                            messages.value.length - 1,
                                            duration:
                                                const Duration(seconds: 0));
                                      }
                                    });
                                    isLoadingPrevMessages.value = false;
                                  },
                                  child: isLoadingPrevMessages.value == false
                                      ? const Text(
                                          'Afișează mesajele anterioare')
                                      : const CircularProgressIndicator(),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(top: 20)),
                                SizeTransition(
                                  axisAlignment: -1.0,
                                  sizeFactor: animation,
                                  child: FadeTransition(
                                    opacity: CurvedAnimation(
                                        curve: Curves.easeIn,
                                        parent: animation),
                                    child: MessageBubble(
                                      chatType: chatType,
                                      pastUID: pastUID,
                                      chatId: chatId,
                                      nextUID: nextUID,
                                      color: theme.value,
                                      data: messages.value[i],
                                      key: UniqueKey(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return SizeTransition(
                              axisAlignment: -1.0,
                              sizeFactor: animation,
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                    curve: Curves.easeIn, parent: animation),
                                child: MessageBubble(
                                  chatType: chatType,
                                  pastUID: pastUID,
                                  chatId: chatId,
                                  nextUID: nextUID,
                                  color: theme.value,
                                  data: messages.value[i],
                                  key: UniqueKey(),
                                ),
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
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: MessageInput(chatId, title, chatType)),
              )
            ],
          ),
        ));
  }
}
