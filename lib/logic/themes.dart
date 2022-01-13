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

final lightTheme = ThemeData(
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

final darkTheme = ThemeData(
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
