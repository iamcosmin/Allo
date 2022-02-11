import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'home.dart';
import 'settings.dart';

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
    final material3InApp = usePreference(ref, material3App, context);
    final locales = S.of(context);
    return Scaffold(
      body: pages[selected.value],
      //? TODO: Old configurations, used for fallback in case of issues with devices.
      //? Remove when migration is done.
      bottomNavigationBar: NavigationBar(
        height: material3InApp.preference == false ? 56 : null,
        labelBehavior: material3InApp.preference == false
            ? NavigationDestinationLabelBehavior.alwaysHide
            : NavigationDestinationLabelBehavior.alwaysShow,
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
