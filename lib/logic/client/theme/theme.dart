import 'dart:io';

import 'package:allo/components/material3/elevation_overlay.dart';
import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/client/theme/ink.dart';
import 'package:allo/logic/client/theme/page_transitions.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'typography.dart';

import '../hooks.dart';

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
  final dynamic12 = sdkInt != null && sdkInt >= 31;
  final themeColor = usePreference(ref, preferredColorPreference);
  final animations = usePreference(ref, animationsPreference);
  final platform = ThemeData().platform;

  ColorScheme getColorScheme() {
    final defaultColorScheme = ColorScheme.fromSeed(
      seedColor: Color(themeColor.preference),
      brightness: brightness,
    );
    if (colorScheme != null) {
      return colorScheme;
    } else {
      if (!kIsWeb && Platform.isAndroid) {
        final dynamicColor = usePreference(ref, dynamicColorPreference);
        if (dynamic12 && dynamicColor.preference) {
          final deviceColorScheme = ref
              .read(dynamicColorsProvider)
              ?.toColorScheme(brightness: brightness);
          return deviceColorScheme ?? defaultColorScheme;
        } else {
          return defaultColorScheme;
        }
      } else {
        return defaultColorScheme;
      }
    }
  }

  final scheme = getColorScheme();

  Color tint(double elevation) {
    return M3ElevationOverlay.applySurfaceTint(
      scheme.surface,
      scheme.primary,
      elevation,
    );
  }

  final iOS = usePreference(ref, emulateIOSBehaviour).preference == true ||
      platform == TargetPlatform.iOS;

  // TODO(iamcosmin): Once all Material3 changes land in beta, we should remove all emulations.
  return ThemeData(
    // These parameters will remain even after Material 3 lands.
    platform: iOS ? TargetPlatform.iOS : null,
    typography: getTypography(),
    pageTransitionsTheme: getPageTransitionsTheme(
      reducedMotion: !animations.preference,
    ),
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    // TODO: Check if change has landed.
    errorColor: scheme.error,
    // These parameters are here just to emulate some of the Material 3 changes that haven't landed yet into the framework.
    splashFactory: inkFeatureHolder,
    shadowColor: scheme.shadow,
    scaffoldBackgroundColor: tint(1),
    backgroundColor: tint(1),
    androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
    // Backward compatibility
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
          fontFamily: iOS ? null : 'GS-Text',
          fontSize: 12,
          letterSpacing: 0.6,
          color: scheme.onSurface,
        ),
      ),
    ),
    applyElevationOverlayColor: true,
    navigationRailTheme: NavigationRailThemeData(
      selectedLabelTextStyle: TextStyle(
        fontFamily: iOS ? null : 'GS-Text',
        fontSize: 12.5,
        color: scheme.onSurface,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontFamily: iOS ? null : 'GS-Text',
        fontSize: 12.5,
        color: scheme.onSurface,
      ),
    ),
    listTileTheme: ListTileThemeData(
      textColor: scheme.onSurface,
      iconColor: scheme.onSurface,
      tileColor: tint(1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(const StadiumBorder()),
        backgroundColor: MaterialStateProperty.all(scheme.primary),
        foregroundColor: MaterialStateProperty.all(scheme.onPrimary),
        splashFactory: inkFeatureHolder,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(const StadiumBorder()),
        foregroundColor: MaterialStateProperty.all(scheme.primary),
        splashFactory: inkFeatureHolder,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(scheme.primary),
        splashFactory: inkFeatureHolder,
      ),
    ),
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        statusBarIconBrightness:
            brightness == Brightness.light ? Brightness.dark : Brightness.light,
        statusBarColor: const Color(0x00000000),
      ),
      foregroundColor: scheme.onSurface,
      backgroundColor: tint(3),
      elevation: 0,
      iconTheme: IconThemeData(
        color: scheme.onSurface,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.primaryContainer,
      actionTextColor: scheme.onPrimaryContainer,
      behavior: SnackBarBehavior.floating,
      contentTextStyle: TextStyle(
        color: scheme.onPrimaryContainer,
      ),
      shape: const StadiumBorder(),
    ),
    toggleableActiveColor: scheme.primary,
  );
}
