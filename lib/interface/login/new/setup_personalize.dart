import 'package:allo/components/setup_page.dart';
import 'package:allo/interface/login/new/setup_done.dart';
import 'package:allo/logic/client/hooks.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/settings_tile.dart';

class SetupPersonalize extends HookConsumerWidget {
  const SetupPersonalize({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = usePreference(ref, darkMode);
    void onSubmit() {
      Core.navigation.push(route: const SetupDone());
    }

    return SetupPage(
      icon: Icons.brush,
      title: Text(context.locale.setupPersonalizeScreenTitle),
      subtitle: Text(context.locale.setupPersonalizeScreenDescription),
      body: [
        Setting(
          title: context.locale.darkMode,
          preference: dark,
        )
      ],
      action: onSubmit,
    );
  }
}
