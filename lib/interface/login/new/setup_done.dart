import 'package:allo/components/oobe_page.dart';
import 'package:allo/interface/home/stack_navigator.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupDone extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final navigation = useProvider(Repositories.navigation);
    return SetupPage(
        header: [
          Text(
            'Ai terminat!',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: Text(
              'Bucură-te de Allo!',
              style:
                  TextStyle(fontSize: 18, color: CupertinoColors.inactiveGray),
              textAlign: TextAlign.left,
            ),
          )
        ],
        body: [],
        onButtonPress: () {
          navigation.pushPermanent(
              context, StackNavigator(), SharedAxisTransitionType.horizontal);
        },
        isAsync: false);
  }
}
