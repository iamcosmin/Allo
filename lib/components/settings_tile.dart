import 'package:allo/components/tile.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingTile extends HookConsumerWidget {
  const SettingTile({
    required this.title,
    super.key,
    this.leading,
    this.enabled = true,
    this.disabledExplanation,
    this.onTap,
    this.preference,
  })  : assert(
          onTap != null || preference != null,
          'You should provide an onTap callback or a preference',
        ),
        assert(
          (onTap != null && preference == null) ||
              (onTap == null && preference != null),
          'You cannot provide both an onTap callback and a preference. Please choose one.',
        );
  final String title;
  final bool enabled;
  final String? disabledExplanation;
  final Widget? leading;
  final void Function()? onTap;
  final Setting? preference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void changePreference() {
      if (preference != null) {
        if (preference is Setting<bool>) {
          final value = preference!.setting;
          preference!.update(!value);
        }
      }
    }

    if (preference != null && preference is Setting<bool>) {
      return SwitchTile(
        leading: leading,
        title: Text(title),
        value: preference!.setting,
        onChanged: preference!.update,
      );
    } else {
      return Tile(
        leading: leading,
        title: Text(title),
        disabled: !enabled,
        subtitle: !enabled ? Text(disabledExplanation!) : null,
        trailing: SizedBox(
          height: 25,
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 19,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        onTap: enabled ? onTap : null,
      );
    }
  }
}
