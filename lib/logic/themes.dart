import 'package:flutter/material.dart';

const pageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.linux: ZoomPageTransitionsBuilder(),
    TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.windows: ZoomPageTransitionsBuilder(),
  },
);

//? TODO: Old configurations, used for fallback in case of issues with devices.
//? Remove when migration is done.
final oldLightTheme = ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF1A76C6),
    ),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.light,
      accentColor: const Color(0xFF1A76C6),
    ),
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF323232),
      actionTextColor: Color(0xFFFFFFFF),
      behavior: SnackBarBehavior.floating,
      contentTextStyle:
          TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'GS-Text'),
    ),
    toggleableActiveColor: const Color(0xFF1A76C6),
    scaffoldBackgroundColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey.shade300,
      selectedItemColor: const Color(0xFF1A76C6),
    ),
    navigationBarTheme: NavigationBarThemeData(
        indicatorColor: const Color(0xFF1A76C6),
        backgroundColor: Colors.grey.shade300),
    fontFamily: 'GS-Text',
    pageTransitionsTheme: pageTransitionsTheme);

final oldDarkTheme = ThemeData(
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF49B3EA),
  ),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
    accentColor: const Color(0xFF49B3EA),
  ),
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey.shade900,
  ),
  pageTransitionsTheme: pageTransitionsTheme,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey.shade800,
    unselectedItemColor: Colors.white,
    selectedItemColor: const Color(0xFF49B3EA),
  ),
  navigationBarTheme: NavigationBarThemeData(
      indicatorColor: const Color(0xFF49B3EA),
      backgroundColor: Colors.grey.shade800),
  fontFamily: 'GS-Text',
  scaffoldBackgroundColor: const Color(0xFF1c1c1c),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF323232),
    actionTextColor: Color(0xFFFFFFFF),
    behavior: SnackBarBehavior.floating,
    contentTextStyle:
        TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'GS-Text'),
  ),
  toggleableActiveColor: const Color(0xFF49B3EA),
);

final lightSeed = ColorScheme.fromSeed(
  seedColor: const Color(0xFF1A76C6),
  brightness: Brightness.light,
);
final lightTheme = ThemeData(
  useMaterial3: true,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: lightSeed.primaryContainer,
    foregroundColor: lightSeed.onPrimaryContainer,
  ),
  splashFactory: InkRipple.splashFactory,
  shadowColor: lightSeed.shadow,
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: lightSeed.surface,
    indicatorColor: lightSeed.secondaryContainer,
    labelTextStyle: MaterialStateProperty.all(
      const TextStyle(fontFamily: 'GS-Text'),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: lightSeed.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: lightSeed.surface,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
  ),
  backgroundColor: lightSeed.surface,
  colorScheme: lightSeed,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: lightSeed.surface,
    elevation: 2,
    iconTheme: IconThemeData(
      color: lightSeed.onSurface,
    ),
  ),
  pageTransitionsTheme: pageTransitionsTheme,
  scaffoldBackgroundColor: lightSeed.surface,
  fontFamily: 'GS-Text',
  //! TODO: IN ALL THEMEDATAS, THERE ARE TEMPORARY FIELDS
  androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF323232),
    actionTextColor: Color(0xFFFFFFFF),
    behavior: SnackBarBehavior.floating,
    contentTextStyle: TextStyle(
      color: Color(0xFFFFFFFF),
      fontFamily: 'GS-Text',
    ),
  ),
  toggleableActiveColor: const Color(0xFF49B3EA),
);

final darkSeed = ColorScheme.fromSeed(
  seedColor: const Color(0xFF49B3EA),
  brightness: Brightness.dark,
);
final darkTheme = ThemeData(
  useMaterial3: true,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: darkSeed.primaryContainer,
    foregroundColor: darkSeed.onPrimaryContainer,
  ),
  splashFactory: InkRipple.splashFactory,
  shadowColor: darkSeed.shadow,
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: darkSeed.surface,
    indicatorColor: darkSeed.secondaryContainer,
    labelTextStyle: MaterialStateProperty.all(
      const TextStyle(fontFamily: 'GS-Text'),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: darkSeed.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100),
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: darkSeed.surface,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
  ),
  backgroundColor: darkSeed.surface,
  colorScheme: darkSeed,
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: darkSeed.surface,
    elevation: 2,
    iconTheme: IconThemeData(
      color: darkSeed.onSurface,
    ),
  ),
  pageTransitionsTheme: pageTransitionsTheme,
  scaffoldBackgroundColor: darkSeed.surface,
  fontFamily: 'GS-Text',
  //! TODO: IN ALL THEMEDATAS, THERE ARE TEMPORARY FIELDS
  androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF323232),
    actionTextColor: Color(0xFFFFFFFF),
    behavior: SnackBarBehavior.floating,
    contentTextStyle: TextStyle(
      color: Color(0xFFFFFFFF),
      fontFamily: 'GS-Text',
    ),
  ),
  toggleableActiveColor: const Color(0xFF49B3EA),
);
