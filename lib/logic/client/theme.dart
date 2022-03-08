import 'dart:io';

import 'package:allo/components/material3/ink_sparkle.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'hooks.dart';

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

  AndroidOverscrollIndicator getOverscrollIndicator() {
    if (kIsWeb) {
      return AndroidOverscrollIndicator.glow;
    } else if (Platform.isAndroid) {
      final sdkInt = ref.read(deviceInfoProvider).version.sdkInt;
      if (sdkInt != null && sdkInt >= 31) {
        return AndroidOverscrollIndicator.stretch;
      } else {
        return AndroidOverscrollIndicator.glow;
      }
    } else {
      throw Exception(
        'The operating system the app is running on is incompatible with this feature. Please make changes in the source code to include custom implementations for the platform you are trying to support.',
      );
    }
  }

  InteractiveInkFeatureFactory getSplashFactory() {
    if (kIsWeb) {
      // Unfortunately, the web versions of Flutter apps are not so performant,
      // so we will use a [NoSplash.splashFactory].
      return NoSplash.splashFactory;
    } else if (Platform.isAndroid) {
      final sdkInt = ref.read(deviceInfoProvider).version.sdkInt;
      if (sdkInt != null && sdkInt >= 31) {
        return InkSparkle.splashFactory;
      } else {
        return InkRipple.splashFactory;
      }
    } else {
      return NoSplash.splashFactory;
    }
  }

  PageTransitionsTheme pageTransitionsTheme() {
    final motion2 = usePreference(ref, motionV2);
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: motion2.preference
            ? SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.horizontal,
                fillColor: scheme.surface)
            : const ZoomPageTransitionsBuilder(),
        TargetPlatform.fuchsia: const FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: motion2.preference
            ? SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.horizontal,
                fillColor: scheme.surface)
            : const ZoomPageTransitionsBuilder(),
      },
    );
  }

  return ThemeData(
    platform: iOS ? TargetPlatform.iOS : null,
    errorColor: scheme.error,
    useMaterial3: true,
    splashFactory: getSplashFactory(),
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
          backgroundColor: MaterialStateProperty.all(scheme.primary),
          foregroundColor: MaterialStateProperty.all(scheme.primary)),
    ),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(scheme.primary))),
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
    androidOverscrollIndicator: getOverscrollIndicator(),
    pageTransitionsTheme: pageTransitionsTheme(),
    scaffoldBackgroundColor: scheme.surface,
    fontFamily: 'GS-Text',
    //! TODO: These fields should be replaced when Material changes land,
    // as these are just emulations of the Material3 behaviour.
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.primaryContainer,
      actionTextColor: scheme.onPrimaryContainer,
      behavior: SnackBarBehavior.floating,
      contentTextStyle: TextStyle(
        color: scheme.onPrimaryContainer,
        fontFamily: 'GS-Text',
      ),
    ),
    toggleableActiveColor: scheme.primary,
  );
}
