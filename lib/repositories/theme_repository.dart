import 'package:allo/repositories/preferences_repository.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theming
/// Theming should be clear and concise. StateNotifier with a List of 2 arguments (dark mode boolean and accent color.)
///
/// Pass to theme manager the arguments of the theme ([true, Colors.red]), then let the manager update the state
/// so the colors and the dark mode value changes in real time.
// TODO

final appThemeProvider = Provider<AppTheme>((ref) => AppTheme(ref));

class AppTheme {
  AppTheme(this.ref);
  final ProviderReference ref;

  Map<TargetPlatform, PageTransitionsBuilder> builders = const {
    TargetPlatform.android: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.scaled,
        fillColor: Colors.transparent),
    TargetPlatform.fuchsia: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.scaled,
        fillColor: Colors.transparent),
    TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.scaled,
        fillColor: Colors.transparent),
    TargetPlatform.linux: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.scaled,
        fillColor: Colors.transparent),
    TargetPlatform.macOS: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.scaled,
        fillColor: Colors.transparent),
    TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.scaled,
        fillColor: Colors.transparent),
  };
}

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final colorsProvider = Provider<ColorsBuilt>((ref) {
  final dark = ref.watch(darkMode);
  return ColorsBuilt(dark);
});

class ColorsBuilt {
  ColorsBuilt(this.darkMode);
  bool darkMode;

  Color returnColor(Color light, Color dark) {
    if (darkMode) {
      return dark;
    } else {
      return light;
    }
  }

  Color get messageBubble =>
      returnColor(const Color(0xFFdbdbdb), const Color(0xFF292929));
  Color get nonColors =>
      returnColor(const Color(0xFFFFFFFF), const Color(0xFF000000));
  Color get messageInput =>
      returnColor(Colors.grey.shade300, Colors.grey.shade900);
  Color get tabBarColor => returnColor(Colors.white, Colors.grey);
  Color get spinnerColor =>
      returnColor(const Color(0xFFD2D2D2), const Color(0xFF363636));
  Color get contrast =>
      returnColor(const Color(0xFF000000), const Color(0xFFFFFFFF));
  Color get tileColor =>
      returnColor(Colors.grey.shade200, Colors.grey.shade900);
  Color get flashingCircleBrightColor =>
      returnColor(Colors.grey.shade100, Colors.grey.shade500);
  Color get flashingCircleDarkColor =>
      returnColor(Colors.grey.shade500, Colors.grey.shade700);
}
