import 'package:allo/repositories/preferences_repository.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeProvider = Provider<AppTheme>((ref) => AppTheme(ref));

class AppTheme {
  AppTheme(this.ref);
  final ProviderReference ref;
  Color get non {
    return ref.read(colorsProvider).nonColors;
  }

  Map<TargetPlatform, PageTransitionsBuilder> get builders {
    return {
      TargetPlatform.android: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.scaled, fillColor: non),
      TargetPlatform.fuchsia: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.scaled, fillColor: non),
      TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.scaled, fillColor: non),
      TargetPlatform.linux: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.scaled, fillColor: non),
      TargetPlatform.macOS: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.scaled, fillColor: non),
      TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.scaled, fillColor: non),
    };
  }

  ThemeData get kLightTheme {
    return ThemeData(
        accentColor: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: builders,
        ),
        fontFamily: 'VarDisplay');
  }

  ThemeData get _kDarkTheme {
    return ThemeData(
        accentColor: Colors.blue,
        brightness: Brightness.dark,
        pageTransitionsTheme: PageTransitionsTheme(builders: builders),
        fontFamily: 'VarDisplay',
        scaffoldBackgroundColor: Colors.black);
  }

  ThemeData getAppThemeData(BuildContext context, bool isDarkModeEnabled) {
    if (isDarkModeEnabled) {
      return _kDarkTheme;
    } else if (!isDarkModeEnabled) {
      return kLightTheme;
    } else {
      return kLightTheme;
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
      returnColor(Colors.grey.shade300, Colors.grey.shade900);
  Color get tabBarColor =>
      returnColor(CupertinoColors.white, CupertinoColors.darkBackgroundGray);
  Color get spinnerColor => returnColor(Color(0xFFD2D2D2), Color(0xFF363636));
  Color get contrast => returnColor(Color(0xFF000000), Color(0xFFFFFFFF));
}
