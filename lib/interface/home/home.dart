import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/chat_list.dart';
import 'package:allo/interface/home/settings/debug/create_chat.dart';
import 'package:allo/logic/client/hooks.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
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

class Home extends HookConsumerWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createChat = usePreference(ref, privateConversations);
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
      body: Column(
        children: const [
          Expanded(child: ChatList()),
        ],
      ),
    );
  }
}
