import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../logic/preferences.dart';

/// Personalisation preferences
final navBarLabels = preference('personalisation_nav_bar_labels');

class PersonalisePage extends HookConsumerWidget {
  const PersonalisePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = usePreference(ref, darkMode);
    final locales = S.of(context);
    final labels = usePreference(ref, navBarLabels);
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.personalise),
      ),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: Text(locales.darkMode),
            secondary: const Icon(Icons.dark_mode_outlined, size: 27),
            value: dark.preference,
            onChanged: (value) => dark.switcher(ref, context),
          ),
          SwitchListTile.adaptive(
            title: Text(locales.personaliseHideNavigationHints),
            secondary: const Icon(Icons.wrap_text_sharp, size: 27),
            value: labels.preference,
            onChanged: (value) => labels.switcher(ref, context),
          ),
        ],
      ),
    );
  }
}
