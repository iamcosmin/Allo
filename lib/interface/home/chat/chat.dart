import 'package:allo/interface/home/chat/chat_details.dart';
import 'package:allo/interface/home/chat/chat_messages_list.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../logic/client/theme.dart';

class ChatScreen extends HookConsumerWidget {
  final ChatType chatType;
  final String title;
  final String chatId;
  const ChatScreen(
      {required this.title,
      required this.chatId,
      required this.chatType,
      Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typing = useState(false);
    final scheme = useState<ColorScheme>(
      ColorScheme.fromSeed(
          seedColor: Colors.blue, brightness: Theme.of(context).brightness),
    );
    final inputModifiers = useState<InputModifier?>(null);
    final brightness = Theme.of(context).brightness;
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
            brightness: Theme.of(context).brightness,
          );
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
                profilePicture: Core.auth.getProfilePicture(
                  chatId,
                  isGroup: chatType == ChatType.group ? true : false,
                ),
                radius: 40,
                initials: Core.auth.returnNameInitials(title),
              ),
            ),
          ],
          title: InkWell(
            onTap: () => Core.navigation.push(
                context: context,
                route: ChatDetails(
                  name: title,
                  chatId: chatId,
                  chatType: chatType,
                )),
            child: Text(
              title,
              style: const TextStyle(
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
                      child: ChatMessagesList(
                        chatId: chatId,
                        chatType: chatType,
                        inputModifiers: inputModifiers,
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
