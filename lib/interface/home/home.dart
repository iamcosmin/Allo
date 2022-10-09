import 'package:allo/components/chat/chat_tile.dart';
import 'package:allo/components/info.dart';
import 'package:allo/components/shimmer.dart';
import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:flutter/rendering.dart';
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
    required super.isExtended,
    super.key,
  }) : super(child: null, onPressed: null);

  @override
  Widget build(context) {
    if (isExtended) {
      return FloatingActionButton.extended(
        onPressed: () => context.go('/create'),
        label: Text(context.loc.createNewChat),
        icon: const Icon(Icons.edit),
      );
    } else {
      return FloatingActionButton(
        onPressed: () => context.go('/create'),
        child: const Icon(Icons.edit),
      );
    }
  }
}

class Home extends HookConsumerWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();
    final createChat = useSetting(ref, privateConversations);
    final chatList = ref.watch(Core.chats.chatListProvider);
    final fabIsExtended = useState(false);
    return NotificationListener(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          if (notification.direction == ScrollDirection.forward &&
              fabIsExtended.value != false) {
            fabIsExtended.value = false;
          } else if ((notification.direction == ScrollDirection.reverse ||
                  notification.direction == ScrollDirection.idle) &&
              fabIsExtended.value != true) {
            fabIsExtended.value = true;
          }
        }
        return true;
      },
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
            : HomeFAB(
                isExtended: fabIsExtended.value,
                key: UniqueKey(),
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
                          return ChatTile(
                            index: index,
                            leading: const ClipOval(
                              child: LoadingContainer(
                                height: 60,
                                width: 60,
                              ),
                            ),
                            title: const LoadingContainer(
                              height: 18,
                              width: 100,
                            ),
                            subtitle: const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: LoadingContainer(
                                height: 12,
                                width: 200,
                              ),
                            ),
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
                          return ChatTile(
                            index: index,
                            title: Text(
                              chat.title,
                              style:
                                  context.theme.textTheme.titleLarge!.copyWith(
                                fontSize: 20,
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              '${type(chat, context)} (${chat.id})',
                              style:
                                  context.theme.textTheme.labelLarge!.copyWith(
                                color: context.colorScheme.outline,
                              ),
                            ),
                            leading: PersonPicture(
                              profilePicture: chat.picture,
                              radius: 60,
                              initials: Core.auth.returnNameInitials(
                                chat.title,
                              ),
                            ),
                            onTap: () =>
                                context.go('/chat/${chat.id}', extra: chat),
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
                return SliverToBoxAdapter(
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
