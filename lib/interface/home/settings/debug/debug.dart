import 'package:allo/components/settings_list.dart';
import 'package:allo/interface/home/settings/debug/account_info.dart';
import 'package:allo/interface/home/settings/debug/typingbubble.dart';
import 'package:allo/logic/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class C extends HookConsumerWidget {
  const C({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(privateConversations);
    final conversationsMethod = ref.watch(privateConversations.notifier);
    final reactions = ref.watch(reactionsDebug);
    final reactionsMethod = ref.watch(reactionsDebug.notifier);
    final replies = ref.watch(repliesDebug);
    final repliesMethod = ref.watch(repliesDebug.notifier);
    final editMessage = ref.watch(editMessageDebug);
    final editMessageMethod = ref.watch(editMessageDebug.notifier);
    final participants = ref.watch(participantsDebug);
    final participantsMethod = ref.watch(participantsDebug.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opțiuni experimentale'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const SettingsListHeader(
              'Aceste opțiuni sunt experimentale și sunt gândite doar pentru testarea internă. Vă rugăm să nu folosiți aceste setări dacă nu știți ce fac.'),
          ListTile(
            title: const Text('Demo indicator scriere'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ExampleIsTyping(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Informații despre cont'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AccountInfo(),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Reacții'),
            value: reactions,
            onChanged: (value) => reactionsMethod.switcher(ref, context),
          ),
          SwitchListTile(
            title: const Text('Răspunde la mesaj'),
            value: replies,
            onChanged: (value) => repliesMethod.switcher(ref, context),
          ),
          SwitchListTile(
            title: const Text('Editare mesaje'),
            value: editMessage,
            onChanged: (value) => editMessageMethod.switcher(ref, context),
          ),
          SwitchListTile(
            title: const Text('Creare conversații'),
            value: conversations,
            onChanged: (value) => conversationsMethod.switcher(ref, context),
          ),
          SwitchListTile(
            title: const Text('Vezi lista cu participanți'),
            value: participants,
            onChanged: (value) => participantsMethod.switcher(ref, context),
          ),
        ],
      ),
    );
  }
}
