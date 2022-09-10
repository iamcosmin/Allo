import 'package:allo/components/material3/switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Switch;

class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    required this.value,
    this.onChanged,
    super.key,
  });

  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return Switch(
          value: value,
          onChanged: onChanged,
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
