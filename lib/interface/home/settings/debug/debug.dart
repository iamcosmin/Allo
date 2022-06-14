import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/account_info.dart';
import 'package:allo/interface/home/settings/debug/example.dart';
import 'package:allo/interface/home/settings/debug/example_sliver.dart';
import 'package:allo/interface/home/settings/debug/typingbubble.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../components/settings_tile.dart';
import '../../../../components/slivers/sliver_scaffold.dart';

class C extends HookConsumerWidget {
  const C({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final conversations = useSetting(ref, privateConversations);
    final reactions = useSetting(ref, reactionsDebug);
    final editMessage = useSetting(ref, editMessageDebug);
    final members = useSetting(ref, membersDebug);
    final iOSMode = useSetting(ref, emulateIOSBehaviour);
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(locales.internalMenu),
      ),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
                left: 15,
                top: 10,
                right: 15,
              ),
              child: Text(
                locales.internalMenuDisclamer,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ListTile(
              title: const Text(
                'Example App (example.dart)',
              ),
              onTap: () => Core.navigation.push(route: const TestApp()),
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
            ListTile(
              title: const Text('Example SliverAppBar'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExampleSliver(),
                ),
              ),
            ),
            InkWell(
              onLongPress: () => reactions.delete(
                context,
              ),
              child: SettingTile(
                title: locales.reactions,
                preference: reactions,
              ),
            ),
            InkWell(
              onLongPress: () => editMessage.delete(
                context,
              ),
              child: SettingTile(
                title: locales.editMessages,
                preference: editMessage,
              ),
            ),
            InkWell(
              onLongPress: () => conversations.delete(
                context,
              ),
              child: SettingTile(
                title: locales.createNewChats,
                preference: conversations,
              ),
            ),
            InkWell(
              onLongPress: () => members.delete(
                context,
              ),
              child: SettingTile(
                title: locales.enableParticipantsList,
                preference: members,
              ),
            ),
            InkWell(
              onLongPress: () => iOSMode.delete(
                context,
              ),
              child: SettingTile(
                title: 'Cupertino behaviour',
                preference: iOSMode,
              ),
            ),
          ]),
        )
      ],
    );
  }
}
