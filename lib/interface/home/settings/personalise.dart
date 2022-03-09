import 'package:allo/components/space.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../logic/client/hooks.dart';
import '../../../logic/client/preferences/manager.dart';

/// Personalisation preferences
final navBarLabels = preference('personalisation_nav_bar_labels');
final turnOffDynamicColor = preference('turn_off_dynamic_color');

class PersonalisePage extends HookConsumerWidget {
  const PersonalisePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = usePreference(ref, darkMode);
    final locales = S.of(context);
    final labels = usePreference(ref, navBarLabels);
    final dynamicColors = usePreference(ref, turnOffDynamicColor);
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.personalise),
      ),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: Text(locales.darkMode),
            value: dark.preference,
            onChanged: (value) => dark.switcher(),
          ),
          SwitchListTile.adaptive(
            title: Text(locales.personaliseHideNavigationHints),
            value: labels.preference,
            onChanged: (value) => labels.switcher(),
          ),
          const Space(1),
          SwitchListTile.adaptive(
            title: const Text('Turn off system accent'),
            value: dynamicColors.preference,
            onChanged: (value) => dynamicColors.switcher(),
          ),
        ],
      ),
    );
  }
}
