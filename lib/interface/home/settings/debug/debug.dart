import 'package:allo/components/settings_list.dart';
import 'package:allo/interface/home/settings/debug/account_info.dart';
import 'package:allo/interface/home/settings/debug/typingbubble.dart';
import 'package:allo/logic/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class C extends HookConsumerWidget {
  const C({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reactions = useState(false);
    final conversations = ref.watch(privateConversations);
    final conversationsMethod = ref.watch(privateConversations.notifier);

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
            title: const Text('Typing bubble'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ExampleIsTyping(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Account info'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AccountInfo(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Reactions'),
            trailing: Switch(
              value: reactions.value,
              onChanged: (value) {
                reactions.value = value;
              },
            ),
          ),
          ListTile(
            title: const Text('Editare mesaje'),
            trailing: Switch(
              value: reactions.value,
              onChanged: (value) {
                reactions.value = value;
              },
            ),
          ),
          ListTile(
            title: const Text('Creare conversații'),
            trailing: Switch(
              value: conversations,
              onChanged: (value) {
                conversationsMethod.switcher(ref, context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
