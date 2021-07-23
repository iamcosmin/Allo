import 'package:allo/repositories/preferences_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeProvider = Provider<AppTheme>((ref) => AppTheme());

class AppTheme {
  static final CupertinoThemeData _kLightTheme = CupertinoThemeData(
    barBackgroundColor: CupertinoColors.systemGroupedBackground,
    brightness: Brightness.light,
    primaryColor: CupertinoColors.activeOrange,
    primaryContrastingColor: CupertinoColors.black,
    scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
    textTheme: CupertinoTextThemeData(),
  );

  static final CupertinoThemeData _kDarkTheme = CupertinoThemeData(
      barBackgroundColor: CupertinoColors.black,
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.activeOrange,
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: CupertinoColors.black,
      textTheme: CupertinoTextThemeData());

  CupertinoThemeData getAppThemeData(
      BuildContext context, bool isDarkModeEnabled) {
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

final colorsProvider = Provider<Colors>((ref) {
  final dark = ref.watch(darkMode);
  return Colors(dark);
});

class Colors {
  Colors(this.darkMode);
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
}
