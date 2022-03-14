import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _VariablePlatform extends HookConsumerWidget {
  const _VariablePlatform({required this.material, this.cupertino, Key? key})
      : super(key: key);
  final Widget? cupertino;
  final Widget material;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = Theme.of(context).platform;
    final optionalCupertino =
        usePreference(ref, emulateIOSBehaviour).preference;
    if (cupertino != null &&
        (optionalCupertino == true ||
            (platform == TargetPlatform.iOS ||
                platform == TargetPlatform.macOS))) {
      return cupertino!;
    } else {
      return material;
    }
  }
}
