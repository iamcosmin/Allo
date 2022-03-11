import 'package:allo/components/oobe_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/new/setup_done.dart';
import 'package:allo/logic/client/hooks.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupPersonalize extends HookConsumerWidget {
  const SetupPersonalize({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final dark = usePreference(ref, darkMode);
    return SetupPage(
      icon: Icons.brush,
      title: context.locale.setupPersonalizeScreenTitle,
      subtitle: context.locale.setupPersonalizeScreenDescription,
      body: [
        SwitchListTile(
          title: Text(locales.darkMode),
          value: dark.preference,
          onChanged: dark.changeValue,
        )
      ],
      action: () async => true,
      nextRoute: const SetupDone(),
    );
  }
}
