import 'package:allo/components/oobe_page.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'login.dart';

class Setup extends HookWidget {
  const Setup({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final navigation = useProvider(Repositories.navigation);
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
          navigation.push(context, const Login());
        },
        isAsync: false);
  }
}
