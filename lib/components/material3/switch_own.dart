import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// TODO: Remove once merged in framework.
// ignore: unused_import
import 'switch.dart' as own;

class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    required this.value,
    this.onChanged,
    this.enabledIcon,
    this.disabledIcon,
    super.key,
  });

  final bool value;
  final IconData? enabledIcon;
  final IconData? disabledIcon;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return SizedBox(
          height: 32,
          width: 52,
          child: own.Switch(
            thumbIcon: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected) &&
                  enabledIcon != null) {
                return Icon(enabledIcon);
              }
              if (!states.contains(MaterialState.selected) &&
                  disabledIcon != null) {
                return Icon(disabledIcon);
              }
              return null;
            }),
            value: value,
            onChanged: onChanged,
          ),
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return SizedBox(
          height: 32,
          width: 52,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        );
    }
  }
}
