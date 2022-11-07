import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/client/theme/page_transitions/page_transitions.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const kDefaultBrandingColor = Color(0xFF6360BF);

extension ColorString on Color {
  String toHexString() {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

ThemeData theme(
  Brightness brightness,
  WidgetRef ref, {
  ColorScheme? colorScheme,
}) {
  final themeColor = useSetting(ref, preferredColorPreference);
  final animations = useSetting(ref, animationsPreference);
  final platform = ThemeData().platform;

  ColorScheme getColorScheme() {
    final systemTheme = ref.watch(customAccentPreference);
    final defaultScheme = ColorScheme.fromSeed(
      seedColor: Color(themeColor.setting),
      brightness: brightness,
    );

    if (colorScheme != null) {
      return colorScheme;
    }

    if (systemTheme) {
      final androidScheme = ref.watch(corePaletteProvider);
      final otherScheme = ref.watch(accentColorProvider);

      if (androidScheme.value != null) {
        return androidScheme.value!.toColorScheme(brightness: brightness)!;
      }

      if (otherScheme.value != null) {
        return ColorScheme.fromSeed(
          seedColor: otherScheme.value!,
          brightness: brightness,
        );
      }
    }
    return defaultScheme;
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

  InteractiveInkFeatureFactory getSplashFactory() {
    switch (iOS ? TargetPlatform.iOS : platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return InkSparkle.splashFactory;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return NoSplash.splashFactory;
    }
  }

  return ThemeData(
    // These parameters will remain even after Material 3 lands.
    platform: iOS ? TargetPlatform.iOS : null,
    fontFamily: 'Jakarta',
    splashFactory: getSplashFactory(),
    iconTheme: IconThemeData(color: scheme.onSurface),
    pageTransitionsTheme: getPageTransitionsTheme(
      reducedMotion: !animations.setting,
      fillColor: scheme.surface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      contentPadding: const EdgeInsets.all(10),
    ),
    visualDensity: VisualDensity.standard,
    useMaterial3: true,
    brightness: brightness,
    applyElevationOverlayColor: true,
    // These parameters are here just to emulate some of the Material 3 changes that haven't landed yet into the framework.
    shadowColor: scheme.shadow,
    scaffoldBackgroundColor: scheme.surface,
    splashColor: scheme.onInverseSurface.withOpacity(0.5),
    // Backward compatibility
    listTileTheme: ListTileThemeData(
      textColor: scheme.onSurface,
      iconColor: scheme.onSurface,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.surfaceVariant,
      actionTextColor: scheme.onSurfaceVariant,
      behavior: SnackBarBehavior.floating,
      contentTextStyle: TextStyle(
        color: scheme.onPrimaryContainer,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    colorScheme: scheme
        .copyWith(background: scheme.surface)
        .copyWith(error: scheme.error),
  );
}
