import 'package:allo/components/setup_page.dart';
import 'package:allo/interface/login/new/setup_done.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/settings_tile.dart';

class SetupPersonalize extends HookConsumerWidget {
  const SetupPersonalize({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = useSetting(ref, darkMode);
    void onSubmit() {
      Navigation.forward(const SetupDone());
    }

    return SetupPage(
      icon: Icons.brush,
      title: Text(context.loc.setupPersonalizeScreenTitle),
      subtitle: Text(context.loc.setupPersonalizeScreenDescription),
      body: [
        SettingTile(
          title: context.loc.darkMode,
          preference: dark,
        )
      ],
      action: onSubmit,
    );
  }
}
