import 'dart:io';

import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/client/theme/page_transitions/page_transitions.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'typography.dart';

extension ColorString on Color {
  String toHexString() {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
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
  final dynamic12 = sdkInt != null && sdkInt >= 31;
  final themeColor = useSetting(ref, preferredColorPreference);
  final animations = useSetting(ref, animationsPreference);
  final platform = ThemeData().platform;

  ColorScheme getColorScheme() {
    final defaultColorScheme = ColorScheme.fromSeed(
      seedColor: Color(themeColor.setting),
      brightness: brightness,
    );
    if (colorScheme != null) {
      return colorScheme;
    } else {
      if (!kIsWeb && Platform.isAndroid) {
        final dynamicColor = useSetting(ref, dynamicColorPreference);
        if (dynamic12 && dynamicColor.setting) {
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
  final iOS = useSetting(ref, emulateIOSBehaviour).setting == true ||
      platform == TargetPlatform.iOS;

  // if (kIsWeb) {
  //   // Injects code directly in JavaScript.
  //   // Use 'default' for a white status bar, and 'black' for a black status bar.
  //   // Only for iOS devices.
  //   const nativeFunction = "setAppleStatusBarType";
  //   switch (brightness) {
  //     case Brightness.light:
  //       js.context.callMethod(nativeFunction, ['default']);
  //       break;
  //     case Brightness.dark:
  //       js.context.callMethod(nativeFunction, ['black']);
  //   }

  //   // Injects code directly in JavaScript.
  //   // Sets meta theme color to the surface generated color; makes PWAs more consistent with native.
  //   js.context.callMethod(
  //     'setBrowserThemeColor',
  //     [scheme.surface.toHexString()],
  //   );
  // }
  return ThemeData(
    // These parameters will remain even after Material 3 lands.
    platform: iOS ? TargetPlatform.iOS : null,
    applyElevationOverlayColor: true,
    typography: getTypography(scheme),
    iconTheme: IconThemeData(color: scheme.onSurface),
    pageTransitionsTheme: getPageTransitionsTheme(
      reducedMotion: !animations.setting,
      fillColor: scheme.surface,
    ),
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    errorColor: scheme.error,
    // These parameters are here just to emulate some of the Material 3 changes that haven't landed yet into the framework.
    shadowColor: scheme.shadow,
    scaffoldBackgroundColor: scheme.surface,
    backgroundColor: scheme.surface,
    // Backward compatibility
    listTileTheme: ListTileThemeData(
      textColor: scheme.onSurface,
      iconColor: scheme.onSurface,
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
