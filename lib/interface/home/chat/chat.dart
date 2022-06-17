import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/interface/home/chat/chat_details.dart';
import 'package:allo/interface/home/chat/chat_messages_list.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/types.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../logic/client/theme/theme.dart';

class ChatScreen extends HookConsumerWidget {
  final Chat chat;
  const ChatScreen({required this.chat, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = useState<ColorScheme>(
      ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Theme.of(context).brightness,
      ),
    );
    final inputModifiers = useState<InputModifier?>(null);
    final brightness = Theme.of(context).brightness;
    useEffect(
      () {
        if (!kIsWeb) {
          FirebaseMessaging.instance.subscribeToTopic(chat.id);
        }
        Database.firestore.collection('chats').doc(chat.id).snapshots().listen(
          (event) {
            scheme.value = ColorScheme.fromSeed(
              seedColor: Color(
                event.data()?['theme'] is int
                    ? event.data()!['theme']
                    : Colors.blue.value,
              ),
              brightness: Theme.of(context).brightness,
            );
          },
        );
        return;
      },
      const [],
    );

    // return Theme(
    //   data: theme(brightness, ref, context, colorScheme: scheme.value),
    //   child: Builder(
    //     builder: (context) {
    //       return Scaffold(
    //         body: SafeArea(
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Expanded(
    //                 child: SScaffold(
    //                   reverseScroll: true,
    //                   topAppBar: SmallTopAppBar(
    //                     title: InkWell(
    //                       onTap: () => Core.navigation
    //                           .push(route: ChatDetails(chat: chat)),
    //                       child: Text(
    //                         chat.title,
    //                         style: const TextStyle(
    //                           fontSize: 25,
    //                           fontWeight: FontWeight.w600,
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                   slivers: [
    //                     SliverToBoxAdapter(
    //                       child: ChatMessagesList(
    //                         chatId: chat.id,
    //                         chatType: chat is PrivateChat
    //                             ? ChatType.private
    //                             : ChatType.group,
    //                         inputModifiers: inputModifiers,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               MessageInput(
    //                 modifier: inputModifiers,
    //                 chatId: chat.id,
    //                 chatName: chat.title,
    //                 chatType:
    //                     chat is PrivateChat ? ChatType.private : ChatType.group,
    //                 theme: scheme.value,
    //               ),
    //             ],
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );

    return Theme(
      data: theme(brightness, ref, context, colorScheme: scheme.value),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(10),
              child: PersonPicture(
                profilePicture: Core.auth.getProfilePicture(
                  chat is GroupChat
                      ? chat.id
                      : chat is PrivateChat
                          ? (chat as PrivateChat).userId
                          : '',
                  isGroup: chat is GroupChat ? true : false,
                ),
                radius: 35,
                initials: Core.auth.returnNameInitials(chat.title),
              ),
            ),
          ],
          title: InkWell(
            onTap: () => Core.navigation.push(route: ChatDetails(chat: chat)),
            child: Text(
              chat.title,
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
                child: ChatMessagesList(
                  chatId: chat.id,
                  chatType:
                      chat is PrivateChat ? ChatType.private : ChatType.group,
                  inputModifiers: inputModifiers,
                ),
              ),
              MessageInput(
                modifier: inputModifiers,
                chatId: chat.id,
                chatName: chat.title,
                chatType:
                    chat is PrivateChat ? ChatType.private : ChatType.group,
                theme: scheme.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
