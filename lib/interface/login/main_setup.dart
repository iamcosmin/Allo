import 'package:allo/components/setup_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'login.dart';

class Setup extends HookWidget {
  const Setup({super.key});
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    return SetupPage(
      icon: Icons.emoji_people,
      title: Text(locales.setupWelcomeScreenTitle),
      subtitle: Text(locales.setupWelcomeScreenDescription),
      action: () async {
        Navigation.push(route: const Login());
      },
    );
  }
}
