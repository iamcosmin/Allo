import 'package:allo/components/chats/chat_tile.dart';
import 'package:allo/components/sliver_scaffold.dart';
import 'package:allo/components/top_app_bar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/create_chat.dart';
import 'package:allo/logic/client/hooks.dart';
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
    final createChat = usePreference(ref, privateConversations);
    final loadChats = useState<Future<List<Chat>?>>(
      Core.chats.getChatsList(),
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: !createChat.preference
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
        refreshIndicator: RefreshIndicator(
          child: Container(),
          onRefresh: () => loadChats.value = Core.chats.getChatsList(),
        ),
        slivers: [
          FutureBuilder<List<Chat>?>(
            future: loadChats.value,
            builder: (context, data) {
              if (data.data != null) {
                return SliverPadding(
                  padding: const EdgeInsets.all(5),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                        childCount: data.data!.length, (context, index) {
                      final chat = data.data![index];
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
                    }),
                  ),
                );
              } else if (data.error != null) {
                final errorMessage =
                    '${context.locale.anErrorOccurred}\n${(data.error is FirebaseException) ? 'Code: ${(data.error! as FirebaseException).code}'
                        '\n'
                        'Element: ${(data.error! as FirebaseException).plugin}'
                        '\n\n'
                        '${(data.error! as FirebaseException).message}' : data.error.toString()}';
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
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
