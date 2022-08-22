import 'package:allo/components/chats/chat_tile.dart';
import 'package:allo/components/empty.dart';
import 'package:allo/components/info.dart';
import 'package:allo/components/shimmer.dart';
import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/create_chat.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../components/person_picture.dart';
import '../../logic/models/chat.dart';
import 'chat/chat.dart';

String type(Chat chat, BuildContext context) {
  final locales = S.of(context);
  if (chat is GroupChat) {
    return locales.group;
  } else if (chat is PrivateChat) {
    return locales.private;
  } else {
    return locales.unknown;
  }
}

class Home extends ConsumerWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createChat = useSetting(ref, privateConversations);
    final chatList = ref.watch(Core.chats.chatListProvider);
    return SScaffold(
      refreshIndicator: RefreshIndicator(
        onRefresh: () => ref.refresh(Core.chats.chatListProvider.future),
        child: const Empty(),
      ),
      topAppBar: LargeTopAppBar(
        title: Text(context.locale.chats),
      ),
      floatingActionButton: !createChat.setting
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigation.forward(const CreateChat()),
              label: Text(context.locale.createNewChat),
              icon: const Icon(Icons.create),
              tooltip: context.locale.createNewChat,
            ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () => Future.delayed(const Duration(seconds: 3)),
        ),
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
                    text: context.locale.noChats,
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
                            style: context.theme.textTheme.titleLarge!.copyWith(
                              fontSize: 20,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            '${type(chat, context)} (${chat.id})',
                            style: context.theme.textTheme.labelLarge!
                                .copyWith(color: context.colorScheme.outline),
                          ),
                          leading: PersonPicture(
                            profilePicture: chat.picture,
                            radius: 60,
                            initials: Core.auth.returnNameInitials(
                              chat.title,
                            ),
                          ),
                          onTap: () => Navigation.forward(
                            ChatScreen(
                              chat: chat,
                            ),
                          ),
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
                  '${context.locale.anErrorOccurred}\n${(error is FirebaseException) ? 'Code: ${error.code}'
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
    );
  }
}
