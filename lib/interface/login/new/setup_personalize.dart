import 'package:allo/components/oobe_page.dart';
import 'package:allo/components/settings_list.dart';
import 'package:allo/interface/login/new/setup_done.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupPersonalize extends HookConsumerWidget {
  const SetupPersonalize({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkMode);
    final darkMethod = ref.watch(darkMode.notifier);
    return SetupPage(
      header: const [
        Text(
          'Personalizează-ți experiența.',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          'Asta este ultima etapă. Alege opțiunile de personalizare dorite.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SettingsListTile(
            title: 'Mod întunecat',
            type: RadiusType.BOTH,
            onTap: () => darkMethod.switcher(ref, context),
            trailing: Switch(
              value: dark,
              onChanged: (value) => darkMethod.switcher(ref, context),
            ),
          ),
        )
      ],
      onButtonPress: () async =>
          Core.navigation.push(context: context, route: const SetupDone()),
      isAsync: true,
    );
  }
}
