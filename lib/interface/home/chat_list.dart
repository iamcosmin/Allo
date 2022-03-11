import 'package:allo/components/builders.dart';
import 'package:allo/interface/home/home.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../components/person_picture.dart';
import 'chat/chat.dart';

class ChatList extends HookConsumerWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadChats = useState<Future<List<Chat>?>>(
      Core.chat('').getChatsList(),
    );
    return RefreshIndicator(
      onRefresh: () => loadChats.value = Core.chat('').getChatsList(),
      child: FutureView<List<Chat>?>(
        future: loadChats.value,
        success: (context, data) {
          return ListView.builder(
            padding: const EdgeInsets.all(5),
            itemCount: data!.length,
            itemBuilder: (BuildContext context, int index) {
              final chat = data[index];
              return ChatTile(
                title: Text(
                  chat.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                subtitle: Text(
                  type(chat, context) + ' (${chat.id})',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondaryContainer
                        .withAlpha(200),
                  ),
                ),
                leading: PersonPicture(
                  profilePicture: chat.picture,
                  radius: 50,
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
          );
        },
        error: (context, error) {
          final errorMessage = context.locale.anErrorOccurred +
              '\n' +
              ((error is FirebaseException)
                  ? 'Code: ${error.code}'
                      '\n'
                      'Element: ${error.plugin}'
                      '\n\n'
                      '${error.message}'
                  : error.toString());
          return Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Center(
              child: SelectableText(
                errorMessage,
              ),
            ),
          );
        },
      ),
    );
  }
}
