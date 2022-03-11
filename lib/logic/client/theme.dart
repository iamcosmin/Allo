import 'dart:io';

import 'package:allo/components/material3/ink_sparkle.dart';
import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';

import 'hooks.dart';

ColorScheme _getColorSchemeFromCorePalette(
    CorePalette palette, Brightness brightness) {
  if (brightness == Brightness.light) {
    return ColorScheme(
        brightness: brightness,
        primary: Color(palette.primary.get(40)),
        onPrimary: Color(palette.primary.get(100)),
        primaryContainer: Color(palette.primary.get(90)),
        onPrimaryContainer: Color(palette.primary.get(10)),
        secondary: Color(palette.secondary.get(40)),
        onSecondary: Color(palette.secondary.get(100)),
        secondaryContainer: Color(palette.secondary.get(90)),
        onSecondaryContainer: Color(palette.secondary.get(10)),
        tertiary: Color(palette.tertiary.get(40)),
        onTertiary: Color(palette.tertiary.get(100)),
        tertiaryContainer: Color(palette.tertiary.get(90)),
        onTertiaryContainer: Color(palette.tertiary.get(10)),
        error: Color(palette.error.get(40)),
        onError: Color(palette.error.get(100)),
        errorContainer: Color(palette.error.get(90)),
        onErrorContainer: Color(palette.error.get(10)),
        background: Color(palette.neutral.get(99)),
        onBackground: Color(palette.neutral.get(10)),
        surface: Color(palette.neutral.get(99)),
        onSurface: Color(palette.neutral.get(10)),
        surfaceVariant: Color(palette.neutralVariant.get(90)),
        onSurfaceVariant: Color(palette.neutralVariant.get(30)),
        outline: Color(palette.neutralVariant.get(50)),
        inversePrimary: Color(palette.primary.get(80)),
        inverseSurface: Color(palette.neutral.get(20)),
        onInverseSurface: Color(palette.neutral.get(95)),
        shadow: Color(palette.neutral.get(0)));
  } else if (brightness == Brightness.dark) {
    return ColorScheme(
        brightness: brightness,
        primary: Color(palette.primary.get(80)),
        onPrimary: Color(palette.primary.get(20)),
        primaryContainer: Color(palette.primary.get(30)),
        onPrimaryContainer: Color(palette.primary.get(90)),
        secondary: Color(palette.secondary.get(80)),
        onSecondary: Color(palette.secondary.get(20)),
        secondaryContainer: Color(palette.secondary.get(30)),
        onSecondaryContainer: Color(palette.secondary.get(90)),
        tertiary: Color(palette.tertiary.get(80)),
        onTertiary: Color(palette.tertiary.get(20)),
        tertiaryContainer: Color(palette.tertiary.get(30)),
        onTertiaryContainer: Color(palette.tertiary.get(90)),
        error: Color(palette.error.get(80)),
        onError: Color(palette.error.get(20)),
        errorContainer: Color(palette.error.get(30)),
        onErrorContainer: Color(palette.error.get(90)),
        background: Color(palette.neutral.get(10)),
        onBackground: Color(palette.neutral.get(90)),
        surface: Color(palette.neutral.get(10)),
        onSurface: Color(palette.neutral.get(90)),
        surfaceVariant: Color(palette.neutralVariant.get(30)),
        onSurfaceVariant: Color(palette.neutralVariant.get(80)),
        outline: Color(palette.neutralVariant.get(60)),
        inversePrimary: Color(palette.primary.get(40)),
        inverseSurface: Color(palette.neutral.get(90)),
        onInverseSurface: Color(palette.neutral.get(20)),
        shadow: Color(palette.neutral.get(0)));
  } else {
    throw Exception('This brightness value is not implemented by the method.');
  }
}

ThemeData theme(
  Brightness brightness,
  WidgetRef ref,
  BuildContext context, {
  ColorScheme? colorScheme,
}) {
  int? sdkInt;
  if (!kIsWeb && Platform.isAndroid) {
    sdkInt = ref.read(androidSdkVersionProvider).sdkInt;
  }
  final dynamic12 = (sdkInt != null && sdkInt >= 31);

  ColorScheme getColorScheme() {
    final defaultColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    );
    if (colorScheme != null) {
      return colorScheme;
    } else {
      if (kIsWeb) {
        return defaultColorScheme;
      } else if (Platform.isAndroid) {
        final turnOffDynamicPreference =
            usePreference(ref, turnOffDynamicColor);
        if (dynamic12 && !turnOffDynamicPreference.preference) {
          final rawColorScheme = ref.read(dynamicColorsProvider);
          if (rawColorScheme != null) {
            return _getColorSchemeFromCorePalette(rawColorScheme, brightness);
          } else {
            return defaultColorScheme;
          }
        } else {
          return defaultColorScheme;
        }
      } else {
        throw Exception(
          'The operating system the app is running on is incompatible with this feature. Please make changes in the source code to include custom implementations for the platform you are trying to support.',
        );
      }
    }
  }

  final scheme = getColorScheme();

  final platform = ThemeData().platform;
  final iOS = usePreference(ref, emulateIOSBehaviour).preference == true ||
      platform == TargetPlatform.iOS;

  AndroidOverscrollIndicator getOverscrollIndicator() {
    if (kIsWeb) {
      return AndroidOverscrollIndicator.glow;
    } else if (Platform.isAndroid) {
      if (dynamic12) {
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
      if (dynamic12) {
        return InkSparkle.splashFactory;
      } else {
        return InkRipple.splashFactory;
      }
    } else {
      return NoSplash.splashFactory;
    }
  }

  PageTransitionsTheme pageTransitionsTheme() {
    PageTransitionsBuilder getAndroid() {
      if (sdkInt != null) {
        if (sdkInt >= 31) {
          return SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: scheme.surface,
          );
        } else if (sdkInt == 29 || sdkInt == 30) {
          return const ZoomPageTransitionsBuilder();
        } else if (sdkInt == 28) {
          return const OpenUpwardsPageTransitionsBuilder();
        } else {
          return const FadeUpwardsPageTransitionsBuilder();
        }
      } else {
        return const FadeUpwardsPageTransitionsBuilder();
      }
    }

    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: getAndroid(),
        TargetPlatform.fuchsia: const FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: scheme.surface,
        ),
      },
    );
  }

  return ThemeData(
    platform: iOS ? TargetPlatform.iOS : null,
    // TODO: Remove once changes land in beta
    errorColor: scheme.error,
    useMaterial3: true,
    splashFactory: getSplashFactory(),
    shadowColor: scheme.shadow,
    scaffoldBackgroundColor: scheme.background,
    // Backward compatibility
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
          fontFamily: iOS ? null : 'GS-Text',
          fontSize: 12,
          letterSpacing: 0.6,
          color: scheme.onSurface,
          inherit: true,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      selectedLabelTextStyle: TextStyle(
          fontFamily: iOS ? null : 'GS-Text',
          fontSize: 12.5,
          color: scheme.onSurface),
      unselectedLabelTextStyle: TextStyle(
          fontFamily: iOS ? null : 'GS-Text',
          fontSize: 12.5,
          color: scheme.onSurface),
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

    // TODO: All the button themes below should be removed when Material 3 button
    // changes land in the beta branch.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(const StadiumBorder()),
        backgroundColor: MaterialStateProperty.all(scheme.primary),
        foregroundColor: MaterialStateProperty.all(scheme.onPrimary),
        splashFactory: getSplashFactory(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(const StadiumBorder()),
        foregroundColor: MaterialStateProperty.all(scheme.primary),
        splashFactory: getSplashFactory(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(scheme.primary),
        splashFactory: getSplashFactory(),
      ),
    ),
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
    fontFamily: iOS ? null : 'GS-Text',
    //! TODO: These fields should be replaced when Material changes land,
    // as these are just emulations of the Material3 behaviour.
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.primaryContainer,
      actionTextColor: scheme.onPrimaryContainer,
      behavior: SnackBarBehavior.floating,
      contentTextStyle: TextStyle(
        color: scheme.onPrimaryContainer,
        fontFamily: iOS ? null : 'GS-Text',
      ),
    ),
    toggleableActiveColor: scheme.primary,
  );
}
