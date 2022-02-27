import 'package:allo/components/person_picture.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/create_chat.dart';
import 'package:allo/logic/client/hooks.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:allo/interface/home/chat/chat.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../logic/models/chat.dart';

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

class ChatTile extends HookConsumerWidget {
  const ChatTile(
      {required this.leading,
      required this.title,
      required this.subtitle,
      required this.onTap,
      Key? key})
      : super(key: key);
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final void Function() onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: leading,
            ),
            const Padding(padding: EdgeInsets.only(left: 10)),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, subtitle],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadChats =
        useState<Future<List<Chat>?>>(Core.chat('').getChatsList());
    final createChat = usePreference(ref, privateConversations);
    final locales = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.chats + (kReleaseMode == false ? ' (Debug)' : '')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onPressed: createChat.preference == false
            ? null
            : () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CreateChat())),
        label: Text(
          locales.createNewChat,
          style: const TextStyle(fontFamily: 'GS-Text', letterSpacing: 0),
        ),
        icon: const Icon(Icons.create_outlined),
      ),
      body: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () => loadChats.value = Core.chat('').getChatsList(),
        child: FutureBuilder<List<Chat>?>(
          future: loadChats.value,
          builder: (BuildContext context, AsyncSnapshot<List<Chat>?> snapshot) {
            if (snapshot.data != null) {
              return ListView.builder(
                padding: const EdgeInsets.all(5),
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  final chat = snapshot.data![index];
                  return ChatTile(
                    title: Text(
                      chat.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    subtitle: Text(
                      type(chat, context) + ' (${chat.id})',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withAlpha(200),
                      ),
                    ),
                    leading: PersonPicture.determine(
                      profilePicture: chat.picture,
                      radius: 50,
                      initials: Core.auth.returnNameInitials(
                        chat.title,
                      ),
                    ),
                    onTap: () => Core.navigation.push(
                      context: context,
                      route: ChatScreen(
                        chatType: getChatTypeFromType(chat),
                        title: chat.title,
                        chatId: chat.id,
                        profilepic: chat.picture,
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              final errorMessage = locales.anErrorOccurred +
                  '\n' +
                  ((snapshot.error is FirebaseException)
                      ? 'Code: ${(snapshot.error as FirebaseException).code}'
                          '\n'
                          'Element: ${(snapshot.error as FirebaseException).plugin}'
                          '\n\n'
                          '${(snapshot.error as FirebaseException).message}'
                      : snapshot.error.toString());
              return Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Center(
                  child: SelectableText(
                    errorMessage,
                  ),
                ),
              );
            } else if (snapshot.data == null) {
              return Center(
                child: Text(locales.noChats),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
