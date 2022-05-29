import 'dart:io';

import 'package:allo/components/settings_tile.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/components/top_app_bar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/sliver_scaffold.dart';
import '../../../logic/client/hooks.dart';
import '../../../logic/client/preferences/manager.dart';

const colors = Colors.accents;

/// Personalisation preferences
final navBarLabelsPreference =
    createPreference('personalisation_nav_bar_labels', false);
final dynamicColorPreference = createPreference('dynamic_color', !kIsWeb);
final preferredColorPreference =
    createPreference('accent_color', Colors.blueAccent.value);
final animationsPreference = createPreference('animations', !kIsWeb);

class PersonalisePage extends HookConsumerWidget {
  const PersonalisePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = usePreference(ref, darkMode);
    final locales = S.of(context);
    final labels = usePreference(ref, navBarLabelsPreference);
    final dynamicColor = usePreference(ref, dynamicColorPreference);
    final themeColor = usePreference(ref, preferredColorPreference);
    final animations = usePreference(ref, animationsPreference);
    int? sdkInt;
    if (!kIsWeb && Platform.isAndroid) {
      sdkInt = ref.read(androidSdkVersionProvider).sdkInt;
    }
    final dynamic12 = sdkInt != null && sdkInt >= 31;
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(locales.personalise),
      ),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            Setting(
              title: locales.darkMode,
              preference: dark,
            ),
            Setting(
              title: locales.personaliseHideNavigationHints,
              preference: labels,
            ),
            Setting(
              enabled: !dynamicColor.preference,
              disabledExplanation: locales.themeColorDisabledExplanation,
              title: locales.themeColor,
              onTap: () => showMagicBottomSheet(
                context: context,
                title: locales.themeColor,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var color in colors) ...[
                          ClipOval(
                            child: InkWell(
                              onTap: () {
                                themeColor.changeValue(color.value);
                                Navigator.of(context).pop();
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    color: color,
                                  ),
                                  if (color.value == themeColor.preference) ...[
                                    Container(
                                      height: 60,
                                      width: 60,
                                      color: Colors.black.withOpacity(0.5),
                                      child: const Icon(
                                        Icons.check,
                                        size: 40,
                                      ),
                                    )
                                  ],
                                ],
                              ),
                            ),
                          )
                        ],
                      ],
                    ),
                  )
                ],
              ),
            ),
            Setting(
              title: locales.animations,
              preference: animations,
            ),
            if (dynamic12) ...[
              Setting(
                title: locales.useSystemColor,
                preference: dynamicColor,
              ),
            ],
          ]),
        )
      ],
    );
  }
}
