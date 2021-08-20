import 'package:allo/repositories/preferences_repository.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeProvider = Provider<AppTheme>((ref) => AppTheme());

class AppTheme {
  static final Map<TargetPlatform, PageTransitionsBuilder> _builders = {
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
  static final _kLightTheme = ThemeData(
      accentColor: Colors.blue,
      brightness: Brightness.light,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: _builders,
      ),
      fontFamily: 'VarDisplay');
  static final _kDarkTheme = ThemeData(
      accentColor: Colors.blue,
      brightness: Brightness.dark,
      pageTransitionsTheme: PageTransitionsTheme(builders: _builders),
      fontFamily: 'VarDisplay',
      scaffoldBackgroundColor: Colors.black);

  ThemeData getAppThemeData(BuildContext context, bool isDarkModeEnabled) {
    if (isDarkModeEnabled) {
      return _kDarkTheme;
    } else if (!isDarkModeEnabled) {
      return _kLightTheme;
    } else {
      return _kLightTheme;
    }
  }
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

  Color get messageBubble => returnColor(Color(0xFFdbdbdb), Color(0xFF292929));
  Color get nonColors => returnColor(Color(0xFFFFFFFF), Color(0xFF000000));
  Color get messageInput =>
      returnColor(Color(0xFFFFFFFF), CupertinoColors.darkBackgroundGray);
  Color get tabBarColor =>
      returnColor(CupertinoColors.white, CupertinoColors.darkBackgroundGray);
  Color get spinnerColor => returnColor(Color(0xFFD2D2D2), Color(0xFF363636));
  Color get contrast => returnColor(Color(0xFF000000), Color(0xFFFFFFFF));
}
