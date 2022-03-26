import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/chat_list.dart';
import 'package:allo/interface/home/settings/debug/create_chat.dart';
import 'package:allo/logic/client/hooks.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/foundation.dart';
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

class ChatTile extends HookConsumerWidget {
  const ChatTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    Key? key,
  }) : super(key: key);
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final void Function() onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 75,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: leading,
            ),
            const Padding(padding: EdgeInsets.only(left: 10)),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
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
    final createChat = usePreference(ref, privateConversations);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.locale.chats + (kReleaseMode == false ? ' (Debug)' : ''),
        ),
      ),
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
        children: [
          const Expanded(child: ChatList()),
        ],
      ),
    );
  }
}
