import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/account_info.dart';
import 'package:allo/interface/home/settings/debug/typingbubble.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class C extends HookConsumerWidget {
  const C({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final conversations = usePreference(ref, privateConversations, context);
    final reactions = usePreference(ref, reactionsDebug, context);
    final replies = usePreference(ref, repliesDebug, context);
    final editMessage = usePreference(ref, editMessageDebug, context);
    final members = usePreference(ref, membersDebug, context);
    final material3InApp = usePreference(ref, material3App, context);
    final material3InChat = usePreference(ref, material3Chat, context);
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.internalMenu),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 7, left: 10, top: 7),
            child: Text(
              locales.internalMenuDisclamer,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ListTile(
            title: Text(locales.internalTypingIndicatorDemo),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ExampleIsTyping(),
              ),
            ),
          ),
          ListTile(
            title: Text(locales.internalAccountInfo),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AccountInfo(),
              ),
            ),
          ),
          InkWell(
            onLongPress: () => reactions.clear(ref, context),
            child: SwitchListTile(
              title: Text(locales.reactions),
              value: reactions.preference,
              onChanged: (value) => reactions.switcher(ref, context),
            ),
          ),
          InkWell(
            onLongPress: () => replies.clear(ref, context),
            child: SwitchListTile(
              title: Text(locales.replyToMessage),
              value: replies.preference,
              onChanged: (value) => replies.switcher(ref, context),
            ),
          ),
          InkWell(
            onLongPress: () => material3InApp.clear(ref, context),
            child: SwitchListTile(
              title: Text(locales.material3App),
              value: material3InApp.preference,
              onChanged: (value) => material3InApp.switcher(ref, context),
            ),
          ),
          InkWell(
            onLongPress: () => material3InChat.clear(ref, context),
            child: SwitchListTile(
              title: Text(locales.material3Chat),
              value: material3InChat.preference,
              onChanged: (value) => material3InChat.switcher(ref, context),
            ),
          ),
          InkWell(
            onLongPress: () => editMessage.clear(ref, context),
            child: SwitchListTile(
              title: Text(locales.editMessages),
              value: editMessage.preference,
              onChanged: (value) => editMessage.switcher(ref, context),
            ),
          ),
          InkWell(
            onLongPress: () => conversations.clear(ref, context),
            child: SwitchListTile(
              title: Text(locales.createNewChats),
              value: conversations.preference,
              onChanged: (value) => conversations.switcher(ref, context),
            ),
          ),
          InkWell(
            onLongPress: () => members.clear(ref, context),
            child: SwitchListTile(
              title: Text(locales.enableParticipantsList),
              value: members.preference,
              onChanged: (value) => members.switcher(ref, context),
            ),
          ),
        ],
      ),
    );
  }
}
