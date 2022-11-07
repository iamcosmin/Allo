import 'dart:developer';

import 'package:allo/components/chat/chat_messages_list.dart';
import 'package:allo/components/chat/message_input.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/types.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../logic/client/theme/theme.dart';

// TODO: Input modifiers as Providers.

final currentNotificationState =
    StateNotifierProvider.autoDispose.family<_NotificationState, bool?, String>(
  (ref, arg) {
    return _NotificationState(ref: ref, id: arg);
  },
);

class _NotificationState extends StateNotifier<bool?> {
  _NotificationState({required this.ref, required this.id}) : super(null) {
    if (!kIsWeb) {
      final notificationEnabled =
          ref.read(preferencesProvider).get('notifications_is_enabled__$id');
      if (notificationEnabled == null) {
        FirebaseMessaging.instance.subscribeToTopic(id);
        ref
            .read(preferencesProvider)
            .set('notifications_is_enabled__$id', true);
        state = true;
        log(
          'Notifications enabled by default in state $id',
          name: 'Notifications',
        );
      } else if (notificationEnabled is bool) {
        state = notificationEnabled;
      }
    } else {
      log(
        'Notifications are not supported on this platform.',
        name: 'Notifications',
      );
    }
  }
  final Ref ref;
  final String id;

  // ignore: avoid_positional_boolean_parameters
  void toggleNotificationState(bool value) {
    if (!kIsWeb) {
      if (value == false) {
        FirebaseMessaging.instance.unsubscribeFromTopic(id);
      } else if (value == true) {
        FirebaseMessaging.instance.subscribeToTopic(id);
      }
      ref.read(preferencesProvider).set('notifications_is_enabled__$id', value);
      log('Notifications set to $value in state $id', name: 'Notifications');

      state = value;
    } else {
      log(
        'Notifications are not supported on this platform.',
        name: 'Notifications',
      );
    }
  }
}

// TODO: Optionally provide a String of chatId in case of navigating via link.
// If opening from the chat list, for economy purposes, use the chat object.
class ChatScreen extends HookConsumerWidget {
  final Chat chat;
  const ChatScreen({required this.chat, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryScrollController = useScrollController();
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
        ref.read(currentNotificationState(chat.id));

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
    //                       onTap: () => Navigation
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
      data: theme(brightness, ref, colorScheme: scheme.value),
      child: Builder(
        builder: (context) {
          return PrimaryScrollController(
            controller: primaryScrollController,
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                actions: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(10),
                    child: Hero(
                      tag: '${chat.id}-PICTURE',
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
                  ),
                ],
                title: InkWell(
                  onTap: () {
                    context.go(
                      '/chats/${chat.id}/details',
                      extra: chat,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        chat.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (chat is GroupChat) ...[
                        Text(
                          '${chat.memberUids.length} membri',
                          style: context.textTheme.labelMedium!.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ChatMessagesList(
                        key: key,
                        chat: chat,
                        inputModifiers: inputModifiers,
                      ),
                    ),
                    MessageInput(
                      modifier: inputModifiers,
                      chatId: chat.id,
                      chatName: chat.title,
                      chatType: chat is PrivateChat
                          ? ChatType.private
                          : ChatType.group,
                      theme: scheme.value,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
