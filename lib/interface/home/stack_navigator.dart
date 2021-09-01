import 'package:allo/repositories/repositories.dart';
import 'package:animations/animations.dart';
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
      body: PageTransitionSwitcher(
          transitionBuilder: (child, animation, secondaryAnimation) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.scaled,
              fillColor: Colors.transparent,
              child: child,
            );
          },
          child: pages[selected.value]),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(FluentIcons.home_16_filled), label: 'Acasă'),
          BottomNavigationBarItem(
              icon: Icon(FluentIcons.settings_20_filled), label: 'Setări')
        ],
        currentIndex: selected.value,
        onTap: (index) => selected.value = index,
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
