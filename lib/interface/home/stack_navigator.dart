import 'package:allo/repositories/repositories.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'chat/chat.dart';
import 'home.dart';
import 'settings.dart';

class StackNavigator extends HookWidget {
  StackNavigator({Key? key}) : super(key: key);
  final List<Widget> pages = [const Home(), const Settings()];

  @override
  Widget build(BuildContext context) {
    final selected = useState(0);
    final navigation = useProvider(Repositories.navigation);
    final pageController = usePageController(initialPage: 0, keepPage: true);

    useEffect(() {
      AwesomeNotifications().actionStream.listen((ReceivedAction event) async {
        await navigation.push(
          context,
          Chat(
            chatType: event.payload!['chatType']!,
            title: event.payload!['chatName']!,
            chatId: event.payload!['chatId']!,
          ),
        );
      });
    }, const []);
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: pages,
        onPageChanged: (index) {
          selected.value = index;
        },
      ),
      bottomNavigationBar: NavigationBar(
        height: 56,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          NavigationDestination(
            icon: const Icon(
              FluentIcons.home_16_regular,
            ),
            label: 'Acasă',
            selectedIcon: Icon(
              FluentIcons.home_16_filled,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          NavigationDestination(
            icon: const Icon(FluentIcons.settings_20_regular),
            label: 'Setări',
            selectedIcon: Icon(
              FluentIcons.settings_20_filled,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
          )
        ],
        selectedIndex: selected.value,
        onDestinationSelected: (index) {
          selected.value = index;
          pageController.animateToPage(index,
              duration: const Duration(milliseconds: 200), curve: Curves.ease);
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
