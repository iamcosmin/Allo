import 'dart:io';

import 'package:allo/components/material3/elevation_overlay.dart';
import 'package:allo/components/material3/ink_sparkle.dart';
import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:animations/animations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'hooks.dart';

class NoPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return child;
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
  final themeColor = usePreference(ref, preferredColor);
  final _animations = usePreference(ref, animations);

  ColorScheme getColorScheme() {
    final defaultColorScheme = ColorScheme.fromSeed(
        seedColor: Color(themeColor.preference), brightness: brightness);
    if (colorScheme != null) {
      return colorScheme;
    } else {
      if (!kIsWeb && Platform.isAndroid) {
        final _dynamicColor = usePreference(ref, dynamicColor);
        if (dynamic12 && _dynamicColor.preference) {
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
        scheme.surface, scheme.primary, elevation);
  }

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
    if (kIsWeb || !_animations.preference) {
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
            fillColor: tint(1),
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

    if (_animations.preference) {
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
    } else {
      return const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: NoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: NoPageTransitionsBuilder(),
          TargetPlatform.iOS: NoPageTransitionsBuilder(),
          TargetPlatform.linux: NoPageTransitionsBuilder(),
          TargetPlatform.macOS: NoPageTransitionsBuilder(),
          TargetPlatform.windows: NoPageTransitionsBuilder(),
        },
      );
    }
  }

  return ThemeData(
    platform: iOS ? TargetPlatform.iOS : null,
    // TODO: Remove once changes land in beta
    errorColor: scheme.error,
    useMaterial3: true,
    splashFactory: getSplashFactory(),
    shadowColor: scheme.shadow,
    scaffoldBackgroundColor: tint(1),
    backgroundColor: tint(1),
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
    applyElevationOverlayColor: true,
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
    listTileTheme: ListTileThemeData(
      textColor: scheme.onSurface,
      iconColor: scheme.onSurface,
      tileColor: tint(1),
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
    splashColor: scheme.onSurface.withOpacity(0.2),
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
      backgroundColor: tint(3),
      elevation: 0,
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
