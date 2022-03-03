import 'package:allo/components/oobe_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../home/settings/debug/debug.dart';
import 'login.dart';

class Setup extends HookWidget {
  const Setup({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    return SetupPage(
      icon: Icons.emoji_people,
      title: locales.setupWelcomeScreenTitle,
      subtitle: locales.setupWelcomeScreenDescription,
      body: const [],
      debug: const C(),
      action: () async {
        return true;
      },
      nextRoute: const Login(),
    );
  }
}
