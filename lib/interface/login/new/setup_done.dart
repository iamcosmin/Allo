import 'package:allo/components/oobe_page.dart';
import 'package:allo/interface/home/tabbed_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupDone extends HookWidget {
  const SetupDone({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SetupPage(
        header: const [
          Text(
            'Ai terminat!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          Padding(
            padding: EdgeInsets.only(right: 10, top: 10),
            child: Text(
              'Bucură-te de Allo!',
              style: TextStyle(fontSize: 17, color: Colors.grey),
              textAlign: TextAlign.left,
            ),
          )
        ],
        body: const [],
        onButtonPress: () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => TabbedNavigator(),
              ),
              (route) => false);
        },
        isAsync: false);
  }
}
