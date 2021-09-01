import 'package:allo/components/oobe_page.dart';
import 'package:allo/components/settings_list.dart';
import 'package:allo/interface/login/new/setup_done.dart';
import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupPersonalize extends HookWidget {
  const SetupPersonalize({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final dark = useProvider(darkMode);
    final darkMethod = useProvider(darkMode.notifier);
    final navigation = useProvider(Repositories.navigation);
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
            onTap: () => darkMethod.switcher(context),
            trailing: Switch(
              value: dark,
              onChanged: (value) => darkMethod.switcher(context),
            ),
          ),
        )
      ],
      onButtonPress: () async => navigation.push(context, const SetupDone()),
      isAsync: true,
    );
  }
}
