import 'package:allo/components/settings_tile.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/client/theme/theme.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/material3/tile.dart';
import '../../../components/slivers/sliver_scaffold.dart';
import '../../../components/tile_card.dart';
import '../../../logic/client/preferences/manager.dart';

const colors = Colors.accents;

/// Personalisation preferences
final navBarLabelsPreference =
    initSetting('personalisation_nav_bar_labels', defaultValue: false);
final customAccentPreference =
    initSetting('custom_accent', defaultValue: false);
final preferredColorPreference =
    initSetting('accent_color', defaultValue: kDefaultBrandingColor.value);
final animationsPreference = initSetting('animations', defaultValue: !kIsWeb);

class PersonalisePage extends HookConsumerWidget {
  const PersonalisePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = useSetting(ref, darkMode);
    final labels = useSetting(ref, navBarLabelsPreference);
    final customAccent = useSetting(ref, customAccentPreference);
    final themeColor = useSetting(ref, preferredColorPreference);
    final animations = useSetting(ref, animationsPreference);

    bool customColorSchemeCompatible() {
      if (ref.watch(corePaletteProvider).hasValue ||
          ref.watch(accentColorProvider).hasValue) {
        return true;
      }
      return false;
    }

    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(context.loc.personalise),
      ),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            [
              TileCard(
                [
                  Tile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: Text(context.loc.darkMode),
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
                    title: context.loc.personaliseHideNavigationHints,
                    preference: labels,
                  ),
                  SettingTile(
                    leading: const Icon(Icons.format_color_fill_rounded),
                    enabled: !customAccent.setting,
                    disabledExplanation:
                        context.loc.themeColorDisabledExplanation,
                    title: context.loc.themeColor,
                    onTap: () => showMagicBottomSheet(
                      context: context,
                      title: context.loc.themeColor,
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
                                        if (color.value ==
                                            themeColor.setting) ...[
                                          Container(
                                            height: 60,
                                            width: 60,
                                            color:
                                                Colors.black.withOpacity(0.5),
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
                    title: context.loc.animations,
                    preference: animations,
                  ),
                  if (customColorSchemeCompatible()) ...[
                    SettingTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: context.loc.useSystemColor,
                      preference: customAccent,
                    ),
                  ],
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
