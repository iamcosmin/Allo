import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NavigationView extends HookConsumerWidget {
  const NavigationView(this.child, {super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = useSetting(ref, navBarLabelsPreference);
    final width = MediaQuery.of(context).size.width;
    useAutomaticKeepAlive();
    NavigationRailLabelType? labelType() {
      if (!labels.setting && width < 1300) {
        return NavigationRailLabelType.all;
      } else {
        return NavigationRailLabelType.none;
      }
    }

    final selectedIndex = GoRouter.of(context).location == '/' ? 0 : 1;

    void onDestinationSelected(int i) {
      if (i == 0) {
        context.go('/');
      }
      if (i == 1) {
        context.go('/settings');
      }
    }

    return Scaffold(
      body: Row(
        children: [
          if (width > 700) ...[
            NavigationRail(
              extended: width > 1300 ? true : false,
              labelType: labelType(),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(
                    Icons.chat_outlined,
                  ),
                  label: Text(context.loc.chats),
                  selectedIcon: const Icon(Icons.chat),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(context.loc.settings),
                  selectedIcon: const Icon(Icons.settings),
                )
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            ),
          ],

          // The page.
          Expanded(
            child: child,
          ),
        ],
      ),
      bottomNavigationBar: width < 700
          ? NavigationBar(
              height: labels.setting ? 60 : null,
              labelBehavior: !labels.setting
                  ? NavigationDestinationLabelBehavior.alwaysShow
                  : NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.chat_outlined),
                  label: context.loc.chats,
                  selectedIcon: const Icon(Icons.chat),
                ).unsplashable(context),
                NavigationDestination(
                  icon: const Icon(
                    Icons.settings_outlined,
                  ),
                  label: context.loc.settings,
                  selectedIcon: const Icon(Icons.settings),
                ).unsplashable(context)
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            )
          : null,
    );
  }
}

extension UnsplashableBarItem on NavigationDestination {
  Widget unsplashable(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
      child: this,
    );
  }
}
