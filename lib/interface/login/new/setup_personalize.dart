import 'package:allo/components/oobe_page.dart';
import 'package:allo/interface/login/new/setup_done.dart';
import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupPersonalize extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final dark = useProvider(darkMode);
    final darkMethod = useProvider(darkMode.notifier);
    final navigation = useProvider(Repositories.navigation);
    return SetupPage(
      header: [
        Text(
          'Personalizează-ți experiența.',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
        ),
        Text(
          'Asta este ultima etapă. Alege opțiunile de personalizare dorite.',
          style: TextStyle(fontSize: 18, color: CupertinoColors.inactiveGray),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        CupertinoFormSection.insetGrouped(
          children: [
            CupertinoFormRow(
              prefix: Text('Mod întunecat'),
              child: CupertinoSwitch(
                  value: dark,
                  onChanged: (value) => darkMethod.switcher(context)),
            ),
          ],
        )
      ],
      onButtonPress: () async => navigation.push(
          context, SetupDone(), SharedAxisTransitionType.horizontal),
      isAsync: true,
    );
  }
}
