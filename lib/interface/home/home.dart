import 'package:allo/components/chats/chat_tile.dart';
import 'package:allo/components/shimmer.dart';
import 'package:allo/components/sliver_scaffold.dart';
import 'package:allo/components/top_app_bar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/create_chat.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:flutter_hooks/flutter_hooks.dart';
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
    final loadChats = useState<Future<List<Chat>?>>(
      Core.chats.getChatsList(),
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: !createChat.setting
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateChat()),
                ),
        label: Text(context.locale.createNewChat),
        icon: const Icon(Icons.create),
        tooltip: context.locale.createNewChat,
      ),
      body: SScaffold(
        topAppBar: LargeTopAppBar(
          title: Text(context.locale.home),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            sliver: FutureBuilder<List<Chat>?>(
              future: loadChats.value,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  final data = snapshot.data!;
                  // If the list is not empty.
                  if (data.isNotEmpty) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final chat = snapshot.data![index];
                          return ChatTile(
                            title: Text(
                              chat.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                            ),
                            subtitle: Text(
                              '${type(chat, context)} (${chat.id})',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer
                                    .withAlpha(200),
                              ),
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
                    );
                  } else {
                    // If the list is empty
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          context.locale.noChats,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                } else if (snapshot.error != null) {
                  // If there is an error
                  final errorMessage =
                      '${context.locale.anErrorOccurred}\n${(snapshot.error is FirebaseException) ? 'Code: ${(snapshot.error! as FirebaseException).code}'
                          '\n'
                          'Element: ${(snapshot.error! as FirebaseException).plugin}'
                          '\n\n'
                          '${(snapshot.error! as FirebaseException).message}' : snapshot.error.toString()}';
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
                } else {
                  // If loading
                  return SliverPadding(
                    padding: const EdgeInsets.all(5.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return const ChatTile(
                            leading: ClipOval(
                              child: LoadingContainer(
                                height: 60,
                                width: 60,
                              ),
                            ),
                            title: LoadingContainer(
                              height: 18,
                              width: 100,
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: LoadingContainer(
                                height: 12,
                                width: 200,
                              ),
                            ),
                            onTap: null,
                          );
                        },
                        childCount: MediaQuery.of(context).size.height ~/ 65,
                      ),
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
