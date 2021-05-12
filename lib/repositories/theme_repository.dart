import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeProvider = Provider<AppTheme>((ref) => AppTheme());

class AppTheme {
  static CupertinoThemeData _kLightTheme = CupertinoThemeData(
      barBackgroundColor: CupertinoColors.extraLightBackgroundGray,
      brightness: Brightness.light,
      primaryColor: CupertinoColors.activeOrange,
      primaryContrastingColor: CupertinoColors.black,
      scaffoldBackgroundColor: CupertinoColors.extraLightBackgroundGray,
      textTheme: CupertinoTextThemeData());

  static CupertinoThemeData _kDarkTheme = CupertinoThemeData(
      barBackgroundColor: CupertinoColors.darkBackgroundGray,
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
