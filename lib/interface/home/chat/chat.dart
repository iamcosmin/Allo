import 'package:allo/components/animated_list/animated_firestore_list.dart';
import 'package:allo/interface/home/chat/chat_details.dart';
import 'package:allo/interface/home/typingbubble.dart';
import 'package:allo/repositories/repositories.dart';
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
class Chat extends HookWidget {
  final String chatType;
  final String title;
  final String chatId;
  Chat(
      {required this.title,
      required this.chatId,
      required this.chatType,
      Key? key})
      : super(key: key);
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  @override
  Widget build(BuildContext context) {
    final auth = useProvider(Repositories.auth);
    final typing = useState(false);
    final theme = useState(Colors.blue);
    final colors = useProvider(Repositories.colors);

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
          var themeIndex = themesId.indexOf(dbThemeId);
          theme.value = themes[themeIndex]['color'];
        },
      );
    }, []);
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
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatDetails(name: title, id: chatId))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.only(right: 10),
                    child: PersonPicture.initials(
                      radius: 37,
                      initials: auth.returnNameInitials(title),
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
                child: NotificationListener(
                  onNotification: (value) {
                    if (value is ScrollNotification) {
                      final before = value.metrics.extentBefore;
                      final max = value.metrics.maxScrollExtent;
                      final min = value.metrics.minScrollExtent;

                      if (before == min) {
                        FocusScope.of(context).unfocus();
                      }
                      if (before == max) {}
                    }
                    return false;
                  },
                  child: Column(
                    children: [
                      Expanded(
                        flex: 10,
                        child: FirestoreAnimatedList(
                          query: FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId)
                              .collection('messages')
                              .orderBy('time', descending: true)
                              .limit(20),
                          key: listKey,
                          linear: false,
                          duration: const Duration(milliseconds: 200),
                          reverse: true,
                          itemBuilder: (context, documentList, animation, i) {
                            final Map pastData, nextData;
                            if (i == 0) {
                              nextData = {'senderUID': 'null'};
                            } else {
                              nextData = documentList![i - 1]!.data() as Map;
                            }
                            if (i == documentList!.length - 1) {
                              pastData = {'senderUID': 'null'};
                            } else {
                              pastData = documentList[i + 1]!.data() as Map;
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
                                  data: documentList[i]!,
                                  key: UniqueKey(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TypingIndicator(
                          bubbleColor: colors.messageBubble,
                          flashingCircleBrightColor:
                              colors.flashingCircleBrightColor,
                          flashingCircleDarkColor:
                              colors.flashingCircleDarkColor,
                          showIndicator: false,
                        ),
                      )
                    ],
                  ),
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
