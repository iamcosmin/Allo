import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/account_info.dart';
import 'package:allo/interface/home/settings/debug/typingbubble.dart';
import 'package:allo/logic/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class C extends HookConsumerWidget {
  const C({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final conversations = ref.watch(privateConversations);
    final conversationsMethod = ref.watch(privateConversations.notifier);
    final reactions = ref.watch(reactionsDebug);
    final reactionsMethod = ref.watch(reactionsDebug.notifier);
    final replies = ref.watch(repliesDebug);
    final repliesMethod = ref.watch(repliesDebug.notifier);
    final editMessage = ref.watch(editMessageDebug);
    final editMessageMethod = ref.watch(editMessageDebug.notifier);
    final members = ref.watch(membersDebug);
    final membersMethod = ref.watch(membersDebug.notifier);
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
          SwitchListTile(
            title: Text(locales.reactions),
            value: reactions,
            onChanged: (value) => reactionsMethod.switcher(ref, context),
          ),
          SwitchListTile(
            title: Text(locales.replyToMessage),
            value: replies,
            onChanged: (value) => repliesMethod.switcher(ref, context),
          ),
          SwitchListTile(
            title: Text(locales.editMessages),
            value: editMessage,
            onChanged: (value) => editMessageMethod.switcher(ref, context),
          ),
          SwitchListTile(
            title: Text(locales.createNewChats),
            value: conversations,
            onChanged: (value) => conversationsMethod.switcher(ref, context),
          ),
          SwitchListTile(
            title: Text(locales.enableParticipantsList),
            value: members,
            onChanged: (value) => membersMethod.switcher(ref, context),
          ),
        ],
      ),
    );
  }
}
