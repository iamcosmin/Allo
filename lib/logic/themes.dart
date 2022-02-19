import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const pageTransitionsTheme = PageTransitionsTheme(
  // Todo: If device is running android 9 or lower, [OpenUpwardsPageTransitionsBuilder] should
  // be used, otherwise ZoomPageTransitionsBuilder.
  builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.windows: ZoomPageTransitionsBuilder(),
  },
);

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
  return ThemeData(
    platform: usePreference(ref, emulateIOSBehaviour).preference == true
        ? TargetPlatform.iOS
        : null,
    useMaterial3: true,
    splashFactory: InkRipple.splashFactory,
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
        const TextStyle(fontFamily: 'GS-Text', fontSize: 12.5),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: scheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: scheme.surface,
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
    pageTransitionsTheme: pageTransitionsTheme,
    scaffoldBackgroundColor: scheme.surface,
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
    toggleableActiveColor: scheme.primary,
  );
}
