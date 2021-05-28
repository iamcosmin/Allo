import 'package:allo/interface/home/secret_settings.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'home.dart';
import 'settings.dart';

class StackNavigator extends HookWidget {
  final List<Widget> pages = [Home(), Settings()];

  @override
  Widget build(BuildContext context) {
    final colors = useProvider(fluentColors);
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: colors.tabBarColor,
          items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home), label: 'Acasă'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings), label: 'Setări')
          ],
        ),
        tabBuilder: (context, index) {
          return pages[index];
        },
      ),
    );
  }
}
