import 'package:allo/components/top_app_bar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/account_info.dart';
import 'package:allo/interface/home/settings/debug/example.dart';
import 'package:allo/interface/home/settings/debug/example_sliver.dart';
import 'package:allo/interface/home/settings/debug/typingbubble.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../components/sliver_scaffold.dart';
import '../../../../logic/client/hooks.dart';

class C extends HookConsumerWidget {
  const C({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final conversations = usePreference(ref, privateConversations);
    final reactions = usePreference(ref, reactionsDebug);
    final editMessage = usePreference(ref, editMessageDebug);
    final members = usePreference(ref, membersDebug);
    final iOSMode = usePreference(ref, emulateIOSBehaviour);
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(locales.internalMenu),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(10),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              Padding(
                padding: const EdgeInsets.only(bottom: 7, left: 10, top: 7),
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
                onLongPress: () => reactions.clear(
                  context,
                ),
                child: SwitchListTile.adaptive(
                  title: Text(locales.reactions),
                  value: reactions.preference,
                  onChanged: reactions.changeValue,
                ),
              ),
              InkWell(
                onLongPress: () => editMessage.clear(
                  context,
                ),
                child: SwitchListTile.adaptive(
                  title: Text(locales.editMessages),
                  value: editMessage.preference,
                  onChanged: editMessage.changeValue,
                ),
              ),
              InkWell(
                onLongPress: () => conversations.clear(
                  context,
                ),
                child: SwitchListTile.adaptive(
                  title: Text(locales.createNewChats),
                  value: conversations.preference,
                  onChanged: conversations.changeValue,
                ),
              ),
              InkWell(
                onLongPress: () => members.clear(
                  context,
                ),
                child: SwitchListTile.adaptive(
                  title: Text(locales.enableParticipantsList),
                  value: members.preference,
                  onChanged: members.changeValue,
                ),
              ),
              InkWell(
                onLongPress: () => iOSMode.clear(
                  context,
                ),
                child: SwitchListTile.adaptive(
                  title: const Text('Cupertino behaviour'),
                  value: iOSMode.preference,
                  onChanged: iOSMode.changeValue,
                ),
              ),
            ]),
          ),
        )
      ],
    );
  }
}
