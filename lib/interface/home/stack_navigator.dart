import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';
import 'settings.dart';

class StackNavigator extends StatelessWidget {
  final List<Widget> pages = [Home(), Settings()];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
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
