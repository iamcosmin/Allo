import 'dart:io';

import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/client/theme/page_transitions.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../hooks.dart';
import 'typography.dart';

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
  final iOS = usePreference(ref, emulateIOSBehaviour).preference == true ||
      platform == TargetPlatform.iOS;

  // TODO(iamcosmin): Once all Material3 changes land in beta, we should remove all emulations.
  return ThemeData(
    // These parameters will remain even after Material 3 lands.
    platform: iOS ? TargetPlatform.iOS : null,
    applyElevationOverlayColor: true,
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
    shadowColor: scheme.shadow,
    scaffoldBackgroundColor: scheme.surface,
    backgroundColor: scheme.surface,
    // Backward compatibility
    listTileTheme: ListTileThemeData(
      textColor: scheme.onSurface,
      iconColor: scheme.onSurface,
      tileColor: scheme.surface,
    ),
    //? Implemented in Flutter 2.13.0-0.4.pre
    // appBarTheme: AppBarTheme(
    //   systemOverlayStyle: SystemUiOverlayStyle(
    //     statusBarBrightness: brightness,
    //     statusBarIconBrightness:
    //         brightness == Brightness.light ? Brightness.dark : Brightness.light,
    //     statusBarColor: const Color(0x00000000),
    //   ),
    //   foregroundColor: scheme.onSurface,
    //   // Workaround for blend with surface.
    //   backgroundColor: ElevationOverlay.applySurfaceTint(
    //     scheme.surface,
    //     scheme.primary,
    //     2,
    //   ),
    //   elevation: 0,
    //   iconTheme: IconThemeData(
    //     color: scheme.onSurface,
    //   ),
    // ),
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
