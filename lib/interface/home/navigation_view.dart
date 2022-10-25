import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NavigationView extends HookConsumerWidget {
  const NavigationView({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gets the index in the navigation bar of a location, based on whether it's a custom one or the current location the user
    //  is located in.
    int getLocationIndex({String? location}) {
      location ??= GoRouter.of(context).location;
      switch (location) {
        case '/chats':
          return 0;
        case '/settings':
          return 1;
        default:
          return -1;
      }
    }

    final labels = useSetting(ref, navBarLabelsPreference);
    final width = MediaQuery.of(context).size.width;
    final selectedIndex = useState(getLocationIndex());
    NavigationRailLabelType? labelType() {
      if (!labels.setting && width < 1300) {
        return NavigationRailLabelType.all;
      } else {
        return NavigationRailLabelType.none;
      }
    }

    void onDestinationSelected(int index) {
      switch (index) {
        case 0:
          selectedIndex.value = 0;
          context.go('/chats');
          break;
        case 1:
          selectedIndex.value = 1;
          context.go('/settings');
          break;
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
              selectedIndex: selectedIndex.value,
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
              onDestinationSelected: onDestinationSelected,
              selectedIndex: selectedIndex.value,
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
