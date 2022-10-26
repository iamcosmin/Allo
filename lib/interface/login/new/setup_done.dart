import 'package:allo/components/oobe_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/tabbed_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupDone extends HookWidget {
  const SetupDone({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    return SetupPage(
        header: [
          Text(
            locales.finishScreenTitle,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: Text(
              locales.finishScreenDescription,
              style: const TextStyle(fontSize: 17, color: Colors.grey),
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
