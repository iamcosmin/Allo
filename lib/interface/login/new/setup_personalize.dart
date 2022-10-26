import 'package:allo/components/oobe_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/new/setup_done.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupPersonalize extends HookConsumerWidget {
  const SetupPersonalize({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final dark = ref.watch(darkMode);
    final darkMethod = ref.watch(darkMode.notifier);
    return SetupPage(
      header: [
        Text(
          locales.setupPersonalizeScreenTitle,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          locales.setupPersonalizeScreenDescription,
          style: const TextStyle(fontSize: 17, color: Colors.grey),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SwitchListTile(
            title: Text(locales.darkMode),
            value: dark,
            onChanged: (value) => darkMethod.switcher(ref, context),
          ),
        )
      ],
      onButtonPress: () async =>
          Core.navigation.push(context: context, route: const SetupDone()),
      isAsync: true,
    );
  }
}
