import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/components/tile_card.dart';
import 'package:allo/interface/home/settings/debug/account_info.dart';
import 'package:allo/interface/home/settings/debug/experiments/example_sliver.dart';
import 'package:allo/interface/home/settings/debug/experiments/physics.dart';
import 'package:allo/interface/home/settings/debug/experiments/typingbubble.dart';
import 'package:allo/interface/home/settings/debug/test_notifications.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/material3/tile.dart';
import '../../../components/settings_tile.dart';
import '../../../components/slivers/sliver_scaffold.dart';

const vapid =
    'BO7JSk4Qa_IVmG5QkFbpZEsEVw6ALNxig9fBudpuG9ZgXhnmR-RuxgUiPWjQXX5EMwoB50H8ZN8fHfsBOqKD_Vo';

final notidProvider = FutureProvider<String?>((ref) {
  return FirebaseMessaging.instance.getToken(vapidKey: vapid);
});

class DebugPage extends HookConsumerWidget {
  const DebugPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = useSetting(ref, privateConversations);
    final reactions = useSetting(ref, reactionsDebug);
    final editMessage = useSetting(ref, editMessageDebug);
    final members = useSetting(ref, membersDebug);
    final iOSMode = useSetting(ref, emulateIOSBehaviour);
    final gradientMessages = useSetting(ref, gradientMessageBubble);
    final notId = ref.watch(notidProvider);
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(context.loc.internalMenu),
      ),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            [
              TileCard([
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    context.loc.internalMenuDisclamer,
                    style: TextStyle(color: context.colorScheme.error),
                  ),
                ),
                notId.when(
                  data: (data) {
                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: SelectableText(
                        'ID: ${data.toString()}',
                        style: TextStyle(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                  error: (error, stack) {
                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: SelectableText(
                        'ID: ${error.toString()}',
                        style: TextStyle(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                  loading: () {
                    return const Padding(
                      padding: EdgeInsets.all(15),
                      child: ProgressBar(),
                    );
                  },
                )
              ]),
              const TileHeading('Experiments'),
              TileCard([
                Tile(
                  title: const Text('Debug Testing'),
                  onTap: () {
                    // context.go('/settings/about/debug/testapp');
                  },
                ),
                Tile(
                  title: Text(context.loc.internalTypingIndicatorDemo),
                  onTap: () {
                    Navigation.forward(const ExampleIsTyping());
                    // context.go('/settings/about/debug/typing');
                  },
                ),
                Tile(
                  title: Text(context.loc.internalAccountInfo),
                  onTap: () {
                    Navigation.forward(const AccountInfo());
                    // context.go('/settings/about/debug/account-info');
                  },
                ),
                Tile(
                  title: const Text('Example SliverAppBar'),
                  onTap: () {
                    Navigation.forward(const ExampleSliver());
                    // context.go('/settings/about/debug/slivers');
                  },
                ),
                Tile(
                  title: const Text('Test Notifications'),
                  onTap: () {
                    Navigation.forward(const TestNotificationsPage());
                    // context.go('/settings/about/debug/notifications');
                  },
                ),
                Tile(
                  title: const Text('Physics Simulation'),
                  onTap: () => Navigation.forward(const PhysicsCardDragDemo()),
                ),
              ]),
              const TileHeading('A/B Testing'),
              TileCard([
                InkWell(
                  onLongPress: () => reactions.delete(context),
                  child: SettingTile(
                    title: context.loc.reactions,
                    preference: reactions,
                  ),
                ),
                InkWell(
                  onLongPress: () => editMessage.delete(context),
                  child: SettingTile(
                    title: context.loc.editMessages,
                    preference: editMessage,
                  ),
                ),
                InkWell(
                  onLongPress: () => conversations.delete(context),
                  child: SettingTile(
                    title: context.loc.createNewChats,
                    preference: conversations,
                  ),
                ),
                InkWell(
                  onLongPress: () => members.delete(context),
                  child: SettingTile(
                    title: context.loc.enableParticipantsList,
                    preference: members,
                  ),
                ),
                InkWell(
                  onLongPress: () => iOSMode.delete(context),
                  child: SettingTile(
                    title: 'Cupertino behaviour',
                    preference: iOSMode,
                  ),
                ),
                InkWell(
                  onLongPress: () => gradientMessages.delete(context),
                  child: SettingTile(
                    title: 'Gradient Message Bubbles',
                    preference: gradientMessages,
                  ),
                ),
              ]),
            ],
          ),
        )
      ],
    );
  }
}
