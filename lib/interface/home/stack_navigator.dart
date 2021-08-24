import 'package:allo/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'home.dart';
import 'settings.dart';

class StackNavigator extends HookWidget {
  final List<Widget> pages = [Home(), Settings()];

  @override
  Widget build(BuildContext context) {
    final selected = useState(0);
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
        items: [
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
