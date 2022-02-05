import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'chat/chat.dart';
import 'home.dart';
import 'settings.dart';

class TabbedNavigator extends HookWidget {
  TabbedNavigator({Key? key}) : super(key: key);
  final List<Widget> pages = [const Home(), const Settings()];

  @override
  Widget build(BuildContext context) {
    final selected = useState(0);
    final locales = S.of(context);

    useEffect(() {
      AwesomeNotifications().actionStream.listen((ReceivedAction event) async {
        await Core.navigation.pushAndRemoveUntilHome(
          context: context,
          route: Chat(
            chatType: event.payload!['chatType']!,
            title: event.payload!['chatName']!,
            chatId: event.payload!['chatId']!,
          ),
        );
      });
      return;
    }, const []);
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
        onDestinationSelected: (index) {
          selected.value = index;
        },
      ),
    );
  }
}
