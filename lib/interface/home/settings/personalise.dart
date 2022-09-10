import 'dart:io';

import 'package:allo/components/settings_tile.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/client/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/material3/tile.dart';
import '../../../components/slivers/sliver_scaffold.dart';
import '../../../logic/client/preferences/manager.dart';

const colors = Colors.accents;

/// Personalisation preferences
final navBarLabelsPreference =
    initSetting('personalisation_nav_bar_labels', defaultValue: false);
final dynamicColorPreference =
    initSetting('dynamic_color', defaultValue: false);
final preferredColorPreference =
    initSetting('accent_color', defaultValue: kDefaultBrandingColor.value);
final animationsPreference = initSetting('animations', defaultValue: !kIsWeb);

class PersonalisePage extends HookConsumerWidget {
  const PersonalisePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = useSetting(ref, darkMode);
    final locales = S.of(context);
    final labels = useSetting(ref, navBarLabelsPreference);
    final dynamicColor = useSetting(ref, dynamicColorPreference);
    final themeColor = useSetting(ref, preferredColorPreference);
    final animations = useSetting(ref, animationsPreference);
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
            Tile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: Text(locales.darkMode),
              trailing: DropdownButton(
                isDense: true,
                borderRadius: BorderRadius.circular(20),
                elevation: 1,
                dropdownColor: ElevationOverlay.applySurfaceTint(
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.primary,
                  1,
                ),
                value: dark.setting,
                onChanged: (value) {
                  dark.update(value.toString());
                },
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.light.toString(),
                    child: const Text('Light'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark.toString(),
                    child: const Text('Dark'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system.toString(),
                    child: const Text('System'),
                  ),
                ],
              ),
            ),
            SettingTile(
              leading: const Icon(Icons.menu_open_outlined),
              title: locales.personaliseHideNavigationHints,
              preference: labels,
            ),
            SettingTile(
              leading: const Icon(Icons.format_color_fill_rounded),
              enabled: !dynamicColor.setting,
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
                                themeColor.update(color.value);
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
                                  if (color.value == themeColor.setting) ...[
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
            SettingTile(
              leading: const Icon(Icons.animation),
              title: locales.animations,
              preference: animations,
            ),
            if (dynamic12) ...[
              SettingTile(
                leading: const Icon(Icons.palette_outlined),
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
