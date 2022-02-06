import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'chat/chat.dart';
import 'home.dart';
import 'settings.dart';

final tabState = StateNotifierProvider<TabState, int>((ref) => TabState());

class TabState extends StateNotifier<int> {
  TabState() : super(0);

  void changePage(int index) {
    state = index;
  }
}

class TabbedNavigator extends HookConsumerWidget {
  TabbedNavigator({Key? key}) : super(key: key);
  final List<Widget> pages = [
    const Home(
      key: Key('home'),
    ),
    const Settings(
      key: Key('settings'),
    )
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState(0);
    void _changeSelected(int index) {
      return ref.watch(tabState.notifier).changePage(index);
    }

    final locales = S.of(context);
    return Scaffold(
      body: pages[selected.value],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: locales.home,
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: locales.settings,
            selectedIcon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          )
        ],
        selectedIndex: selected.value,
        onDestinationSelected: (i) => selected.value = i,
      ),
    );
  }
}
