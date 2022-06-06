import 'package:allo/components/switch.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingTile extends HookConsumerWidget {
  const SettingTile({
    required this.title,
    super.key,
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

    return InkWell(
      onTap: enabled ? onTap ?? changePreference : null,
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(enabled ? 1 : 0.5),
                        ),
                  ),
                ),
                if (preference != null && preference is Setting<bool>) ...[
                  SizedBox(
                    height: 32,
                    child: AdaptiveSwitch(
                      value: preference!.setting,
                      // onChanged: null,
                      onChanged: preference!.update,
                    ),
                  )
                ] else ...[
                  SizedBox(
                    height: 25,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 19,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                ]
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: enabled == false && disabledExplanation != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        disabledExplanation!,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
