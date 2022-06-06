import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'home.dart';
import 'settings.dart';

const _kPages = [
  Home(
    key: ValueKey('home'),
  ),
  Settings(
    key: ValueKey('settings'),
  )
];

class TabbedNavigator extends HookConsumerWidget {
  const TabbedNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState(0);
    final previousSelected = usePrevious(selected.value);
    final labels = useSetting(ref, navBarLabelsPreference);
    final animations = useSetting(ref, animationsPreference);
    final locales = S.of(context);
    final width = MediaQuery.of(context).size.width;
    NavigationRailLabelType? labelType() {
      if (width < 1000) {
        if (!labels.setting) {
          return NavigationRailLabelType.all;
        } else {
          return NavigationRailLabelType.none;
        }
      } else {
        return null;
      }
    }

    return Scaffold(
      body: Row(
        children: [
          if (width > 700) ...[
            Container(
              constraints: width > 1300
                  ? const BoxConstraints(maxWidth: 256)
                  : const BoxConstraints(maxWidth: 80),
              child: NavigationRail(
                extended: width > 1300 ? true : false,
                labelType: labelType(),
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(
                      Icons.chat_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    label: Text(locales.chats),
                    selectedIcon: Icon(
                      Icons.chat,
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
            ),
          ],

          // The page.
          Expanded(
            child: PageTransitionSwitcher(
              reverse: (previousSelected ?? 0) > selected.value ? true : false,
              child: _kPages[selected.value],
              transitionBuilder: (child, animation, secondaryAnimation) {
                if (animations.setting) {
                  return SharedAxisTransition(
                    transitionType: width > 700
                        ? SharedAxisTransitionType.vertical
                        : SharedAxisTransitionType.horizontal,
                    fillColor: Theme.of(context).backgroundColor,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  );
                } else {
                  return child;
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: width < 700
          ? NavigationBar(
              height: labels.setting == false ? 70 : 60,
              labelBehavior: !labels.setting
                  ? NavigationDestinationLabelBehavior.alwaysShow
                  : NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.chat_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  label: locales.chats,
                  selectedIcon: Icon(
                    Icons.chat,
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
