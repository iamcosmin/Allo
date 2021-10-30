import 'package:allo/components/scale_page_transition.dart';
import 'package:flutter/material.dart';

const pageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: ScalePageTransitionBuilder(),
    TargetPlatform.fuchsia: ScalePageTransitionBuilder(),
    TargetPlatform.iOS: ScalePageTransitionBuilder(),
    TargetPlatform.linux: ScalePageTransitionBuilder(),
    TargetPlatform.macOS: ScalePageTransitionBuilder(),
    TargetPlatform.windows: ScalePageTransitionBuilder(),
  },
);

final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.light,
      accentColor: const Color(0xFF1A76C6),
    ),
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
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
);
