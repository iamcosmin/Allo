import 'package:allo/components/chat/chat_tile.dart';
import 'package:allo/components/info.dart';
import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../components/empty.dart';
import '../../components/person_picture.dart';
import '../../logic/models/chat.dart';

String type(Chat chat, BuildContext context) {
  if (chat is GroupChat) {
    return context.loc.group;
  } else if (chat is PrivateChat) {
    return context.loc.private;
  } else {
    return context.loc.unknown;
  }
}

class HomeFAB extends FloatingActionButton {
  const HomeFAB({
    // required super.isExtended,
    super.key,
  }) : super(child: null, onPressed: null);

  @override
  Widget build(context) {
    // if (isExtended) {
    return FloatingActionButton.extended(
      onPressed: () => context.go('/chats/create'),
      label: Text(context.loc.createNewChat),
      icon: const Icon(Icons.edit),
    );
    // } else {

    // }
  }
}

class Home extends HookConsumerWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();
    final createChat = useSetting(ref, privateConversations);
    final chatList = ref.watch(Core.chats.chatListProvider);
    // final fabIsExtended = useState(false);
    return NotificationListener(
      // onNotification: (notification) {
      //   if (notification is UserScrollNotification) {
      //     if (notification.direction == ScrollDirection.forward &&
      //         fabIsExtended.value != false) {
      //       fabIsExtended.value = false;
      //     } else if ((notification.direction == ScrollDirection.reverse ||
      //             notification.direction == ScrollDirection.idle) &&
      //         fabIsExtended.value != true) {
      //       fabIsExtended.value = true;
      //     }
      //   }
      //   return true;
      // },
      child: SScaffold(
        refreshIndicator: RefreshIndicator(
          onRefresh: () => ref.refresh(Core.chats.chatListProvider.future),
          child: const Empty(),
        ),
        topAppBar: LargeTopAppBar(
          title: Text(context.loc.chats),
        ),
        floatingActionButton: !createChat.setting
            ? null
            : const HomeFAB(
                // isExtended: fabIsExtended.value,
                ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            sliver: chatList.when(
              loading: () {
                return SliverPadding(
                  padding: const EdgeInsets.all(5.0),
                  sliver: AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ChatTile.placeholder(
                            index: index,
                          );
                        },
                        childCount: MediaQuery.of(context).size.height ~/ 65,
                      ),
                    ),
                  ),
                );
              },
              data: (data) {
                if (data.isEmpty) {
                  return SliverFillRemaining(
                    child: InfoWidget(
                      text: context.loc.noChats,
                    ),
                  );
                } else {
                  return AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final chat = data[index];
                          String getMessage() {
                            final message = chat.lastMessage;
                            if (message != null) {
                              if (message is TextMessage) {
                                return chat is GroupChat ||
                                        message.userId !=
                                            FirebaseAuth
                                                .instance.currentUser?.uid
                                    ? '${message.name}: ${message.text}'
                                    : message.text;
                              } else if (message is ImageMessage) {
                                return chat is GroupChat ||
                                        message.userId !=
                                            FirebaseAuth
                                                .instance.currentUser?.uid
                                    ? '${message.name}: ${context.loc.image}'
                                    : context.loc.image;
                              } else {
                                return chat is GroupChat ||
                                        message.userId !=
                                            FirebaseAuth
                                                .instance.currentUser?.uid
                                    ? '${message.name}: ${context.loc.unsupportedMessage}'
                                    : context.loc.unsupportedMessage;
                              }
                            } else {
                              return '${type(chat, context)} (${chat.id})';
                            }
                          }

                          return ChatTile(
                            index: index,
                            key: ValueKey(chat.id),
                            transitionKey: ValueKey(getMessage()),
                            title: Text(
                              chat.title,
                              style:
                                  context.theme.textTheme.titleLarge!.copyWith(
                                fontSize: 20,
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              getMessage().replaceAll('\n', '  '),
                              key: ValueKey(getMessage()),
                              style:
                                  context.theme.textTheme.labelLarge!.copyWith(
                                color: context.colorScheme.outline,
                              ),
                            ),
                            leading: Hero(
                              tag: '${chat.id}-PICTURE',
                              child: PersonPicture(
                                profilePicture: chat.picture,
                                radius: 60,
                                initials: Core.auth.returnNameInitials(
                                  chat.title,
                                ),
                              ),
                            ),
                            onTap: () =>
                                context.go('/chats/${chat.id}', extra: chat),
                          );
                        },
                        childCount: data.length,
                      ),
                    ),
                  );
                }
              },
              error: (error, stackTrace) {
                final errorMessage =
                    '${context.loc.anErrorOccurred}\n${(error is FirebaseException) ? 'Code: ${error.code}'
                        '\n'
                        'Element: ${error.plugin}'
                        '\n\n'
                        '${error.message}' : error.toString()}';
                return SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Center(
                      child: SelectableText(
                        errorMessage,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
