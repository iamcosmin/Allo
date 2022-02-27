import 'package:allo/components/oobe_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'login.dart';

class Setup extends HookWidget {
  const Setup({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    return SetupPage(
      header: [
        Text(
          locales.setupWelcomeScreenTitle,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 10),
          child: Text(
            locales.setupWelcomeScreenDescription,
            style: const TextStyle(fontSize: 17, color: Colors.grey),
            textAlign: TextAlign.left,
          ),
        )
      ],
      body: const [],
      action: () async {
        return true;
      },
      nextRoute: const Login(),
    );
  }
}
