import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/hooks.dart';
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
    final labels = usePreference(ref, navBarLabels);
    final locales = S.of(context);
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Row(
        children: [
          if (width > 700) ...[
            NavigationRail(
              labelType: labels.preference == false
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.none,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  label: Text(locales.home),
                  selectedIcon: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  label: Text(locales.settings),
                  selectedIcon: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                )
              ],
              selectedIndex: selected.value,
              onDestinationSelected: (i) => selected.value = i,
            ),
          ],
          Expanded(child: pages[selected.value]),
        ],
      ),
      bottomNavigationBar: width < 700
          ? NavigationBar(
              height: labels.preference == false ? 70 : 60,
              labelBehavior: labels.preference == false
                  ? NavigationDestinationLabelBehavior.alwaysShow
                  : NavigationDestinationLabelBehavior.alwaysHide,
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
            )
          : null,
    );
  }
}
