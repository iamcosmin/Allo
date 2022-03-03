import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'hooks.dart';

PageTransitionsTheme pageTransitionsTheme(
    WidgetRef ref, ColorScheme colorScheme) {
  final motion2 = usePreference(ref, motionV2);
  return PageTransitionsTheme(
    builders: {
      TargetPlatform.android: motion2.preference
          ? SharedAxisPageTransitionsBuilder(
              transitionType: SharedAxisTransitionType.horizontal,
              fillColor: colorScheme.surface)
          : const ZoomPageTransitionsBuilder(),
      TargetPlatform.fuchsia: const FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: const ZoomPageTransitionsBuilder(),
    },
  );
}

ThemeData theme(
  Brightness brightness,
  WidgetRef ref,
  BuildContext context, {
  ColorScheme? colorScheme,
}) {
  final scheme = colorScheme ??
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A76C6),
        brightness: brightness,
      );
  final platform = ThemeData().platform;
  final iOS = usePreference(ref, emulateIOSBehaviour).preference == true ||
      platform == TargetPlatform.iOS;
  return ThemeData(
    platform: iOS ? TargetPlatform.iOS : null,
    errorColor: scheme.error,
    useMaterial3: true,
    splashFactory: iOS ? NoSplash.splashFactory : InkRipple.splashFactory,
    shadowColor: scheme.shadow,
    cardTheme: CardTheme(
      color: scheme.surface,
      shadowColor: scheme.shadow,
      elevation: 5,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
            fontFamily: 'GS-Text', fontSize: 12.5, color: scheme.onSurface),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      selectedLabelTextStyle: TextStyle(
          fontFamily: 'GS-Text', fontSize: 12.5, color: scheme.onSurface),
      unselectedLabelTextStyle: TextStyle(
          fontFamily: 'GS-Text', fontSize: 12.5, color: scheme.onSurface),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: scheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: scheme.surface,
      alignment: Alignment.center,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    listTileTheme: ListTileThemeData(
      textColor: scheme.onSurface,
      iconColor: scheme.onSurface,
      tileColor: scheme.surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStateProperty.all(const StadiumBorder()),
          backgroundColor: MaterialStateProperty.all(scheme.primary),
          foregroundColor: MaterialStateProperty.all(scheme.onPrimary)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStateProperty.all(const StadiumBorder()),
          backgroundColor: MaterialStateProperty.all(scheme.surface),
          foregroundColor: MaterialStateProperty.all(scheme.onSurface)),
    ),
    backgroundColor: scheme.surface,
    colorScheme: scheme,
    brightness: brightness,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        statusBarIconBrightness:
            brightness == Brightness.light ? Brightness.dark : Brightness.light,
        statusBarColor: const Color(0x00000000),
      ),
      foregroundColor: scheme.onSurface,
      backgroundColor: scheme.surface,
      elevation: 2,
      iconTheme: IconThemeData(
        color: scheme.onSurface,
      ),
    ),
    pageTransitionsTheme: pageTransitionsTheme(ref, scheme),
    scaffoldBackgroundColor: scheme.surface,
    fontFamily: 'GS-Text',
    //! TODO: IN ALL THEMEDATAS, THERE ARE TEMPORARY FIELDS
    androidOverscrollIndicator: AndroidOverscrollIndicator.glow,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF323232),
      actionTextColor: Color(0xFFFFFFFF),
      behavior: SnackBarBehavior.floating,
      contentTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontFamily: 'GS-Text',
      ),
    ),
    toggleableActiveColor: scheme.primary,
  );
}
