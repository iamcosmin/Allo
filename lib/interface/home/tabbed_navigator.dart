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

    useEffect(() {
      AwesomeNotifications().actionStream.listen((ReceivedAction event) async {
        await Core.navigation.push(
          context: context,
          route: Chat(
            chatType: event.payload!['chatType']!,
            title: event.payload!['chatName']!,
            chatId: event.payload!['chatId']!,
          ),
        );
      });
    }, const []);
    return Scaffold(
      body: pages[selected.value],
      bottomNavigationBar: NavigationBar(
        height: 56,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          NavigationDestination(
            icon: const Icon(
              Icons.home_outlined,
            ),
            label: 'Acasă',
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: 'Setări',
            selectedIcon: Icon(
              Icons.settings,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
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

class StringUtils {
  static final RegExp _emptyRegex = RegExp(r'^\s*$');
  static bool isNullOrEmpty(String? value,
      {bool considerWhiteSpaceAsEmpty = true}) {
    if (considerWhiteSpaceAsEmpty) {
      return value == null || _emptyRegex.hasMatch(value);
    }
    return value?.isEmpty ?? true;
  }
}
