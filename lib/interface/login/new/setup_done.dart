import 'package:allo/components/oobe_page.dart';
import 'package:allo/interface/home/stack_navigator.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupDone extends HookWidget {
  const SetupDone({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final navigation = useProvider(Repositories.navigation);
    return SetupPage(
        header: const [
          Text(
            'Ai terminat!',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          Padding(
            padding: EdgeInsets.only(right: 10, top: 10),
            child: Text(
              'Bucură-te de Allo!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.left,
            ),
          )
        ],
        body: const [],
        onButtonPress: () {
          navigation.pushPermanent(
              context, StackNavigator(), SharedAxisTransitionType.horizontal);
        },
        isAsync: false);
  }
}
