import 'package:allo/logic/client/preferences/manager.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Preference<T> {
  const Preference(this.preference, this.changeValue, this.clear);
  final T preference;
  final void Function(T value) changeValue;
  final void Function(BuildContext) clear;
}

Preference<T> usePreference<T>(
  WidgetRef ref,
  StateNotifierProvider<PreferenceManager<T>, T> provider,
) {
  return Preference<T>(
    ref.watch(provider),
    ref.watch(provider.notifier).changeValue,
    ref.watch(provider.notifier).cleanPreference,
  );
}
