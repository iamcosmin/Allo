import 'package:allo/components/builders.dart';
import 'package:allo/components/chats/chat_tile.dart';
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
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:flutter_hooks/flutter_hooks.dart';
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

class Home extends HookConsumerWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createChat = useSetting(ref, privateConversations);
    final loadChats = useState<Future<List<Chat>>>(
      Core.chats.getChatsList(),
    );
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(context.locale.chats),
      ),
      floatingActionButton: !createChat.setting
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Core.navigation.push(route: const CreateChat()),
              label: Text(context.locale.createNewChat),
              icon: const Icon(Icons.create),
              tooltip: context.locale.createNewChat,
            ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          sliver: FutureWidget<List<Chat>>(
            future: loadChats.value,
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
            success: (data) {
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
                          onTap: () => Core.navigation.push(
                            route: ChatScreen(
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
            error: (error) {
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
