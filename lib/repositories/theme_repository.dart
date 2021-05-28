import 'package:fluent_ui/fluent_ui.dart';
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

final appThemeStateProvider =
    StateNotifierProvider<AppThemeNotifier, bool>((ref) {
  final _kIsDarkModeEnabled =
      ref.read(sharedUtilityProvider).isDarkModeEnabled();
  return AppThemeNotifier(_kIsDarkModeEnabled);
});

class AppThemeNotifier extends StateNotifier<bool> {
  AppThemeNotifier(this.defaultDarkModeValue) : super(defaultDarkModeValue);

  final bool defaultDarkModeValue;

  void switchToLight(BuildContext context) {
    context
        .read(sharedUtilityProvider)
        .disableDarkMode()
        .whenComplete(() => {state = false});
  }

  void switchToDark(BuildContext context) {
    context
        .read(sharedUtilityProvider)
        .enableDarkMode()
        .whenComplete(() => {state = true});
  }
}

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final sharedUtilityProvider = Provider<SharedUtility>((ref) {
  final _sharedPreferences = ref.watch(sharedPreferencesProvider);
  return SharedUtility(sharedPreferences: _sharedPreferences);
});

class SharedUtility {
  SharedUtility({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  String returnResult(String parameter) {
    return sharedPreferences.getString(parameter) ?? '';
  }

  bool isParamEnabled(String parameter) {
    return sharedPreferences.getBool(parameter) ?? false;
  }

  Future<bool> enableParam(String parameter) async {
    return await sharedPreferences.setBool(parameter, true);
  }

  Future<bool> disableParam(String parameter) async {
    return await sharedPreferences.setBool(parameter, false);
  }

  bool isDarkModeEnabled() {
    return sharedPreferences.getBool('isDarkModeEnabled') ?? false;
  }

  Future<bool> enableDarkMode() async {
    return await sharedPreferences.setBool('isDarkModeEnabled', true);
  }

  Future<bool> disableDarkMode() async {
    return await sharedPreferences.setBool('isDarkModeEnabled', false);
  }
}

final fluentColors = Provider<FluentColors>((ref) {
  final darkMode = ref.watch(appThemeStateProvider);
  return FluentColors(darkMode);
});

class FluentColors {
  FluentColors(this.darkMode);
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
