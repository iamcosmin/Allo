import 'package:allo/components/oobe_page.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'login.dart';

class Setup extends HookWidget {
  const Setup({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SetupPage(
        header: const [
          Text(
            'Bine ai venit la Allo!',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          Padding(
            padding: EdgeInsets.only(right: 10, top: 10),
            child: Text(
              'Comunică simplu și ușor cu persoanele dragi ție în siguranță și confort.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.left,
            ),
          )
        ],
        body: const [],
        onButtonPress: () {
          Core.navigation.push(context: context, route: const Login());
        },
        isAsync: false);
  }
}
