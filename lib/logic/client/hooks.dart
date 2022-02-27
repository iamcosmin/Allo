import 'package:allo/logic/client/preferences/manager.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Preference {
  const Preference(this.preference, this.switcher, this.clear);
  final bool preference;
  final void Function() switcher;
  final void Function(BuildContext) clear;
}

Preference usePreference(
  WidgetRef ref,
  StateNotifierProvider<PreferenceManager, bool> provider,
) {
  return Preference(
    ref.watch(provider),
    ref.watch(provider.notifier).switcher,
    ref.watch(provider.notifier).cleanPreference,
  );
}
