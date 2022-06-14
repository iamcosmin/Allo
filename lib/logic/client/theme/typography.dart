import 'package:flutter/material.dart';

/// Returns a [Typography] element.
/// For Android, the default font will be Google Sans Display and Google Sans Text
/// For the rest of the platforms, the default fonts remain.
/// The typography is strictly in relation with Material 3.
Typography getTypography(ColorScheme colorScheme) {
  final platform = ThemeData().platform;
  String displayFont, textFont;
  switch (platform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      displayFont = 'Display';
      textFont = 'Text';
      break;
    // case TargetPlatform.iOS:
    // case TargetPlatform.macOS:
    //   displayFont, color: color, = '.SF UI Display';
    //   textFont, color: color, = '.SF UI Text';
  }

  final typography = Typography.material2021();
  // Color that will be by default on the surface.
  final color = colorScheme.onSurface;
  return Typography(
    black: TextTheme(
      displayLarge: typography.black.displayLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      displayMedium: typography.black.displayMedium?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      displaySmall: typography.black.displaySmall?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineLarge: typography.black.headlineLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineMedium: typography.black.headlineMedium?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineSmall: typography.black.headlineSmall?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      titleLarge: typography.black.titleLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      titleMedium: typography.black.titleMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      titleSmall: typography.black.titleSmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodyLarge: typography.black.bodyLarge?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodyMedium: typography.black.bodyMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodySmall: typography.black.bodySmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelLarge: typography.black.labelLarge?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelMedium: typography.black.labelMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelSmall: typography.black.labelSmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
    ),
    dense: TextTheme(
      displayLarge: typography.dense.displayLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      displayMedium: typography.dense.displayMedium?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      displaySmall: typography.dense.displaySmall?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineLarge: typography.dense.headlineLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineMedium: typography.dense.headlineMedium?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineSmall: typography.dense.headlineSmall?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      titleLarge: typography.dense.titleLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      titleMedium: typography.dense.titleMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      titleSmall: typography.dense.titleSmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodyLarge: typography.dense.bodyLarge?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodyMedium: typography.dense.bodyMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodySmall: typography.dense.bodySmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelLarge: typography.dense.labelLarge?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelMedium: typography.dense.labelMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelSmall: typography.dense.labelSmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
    ),
    englishLike: TextTheme(
      displayLarge: typography.englishLike.displayLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      displayMedium: typography.englishLike.displayMedium?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      displaySmall: typography.englishLike.displaySmall?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineLarge: typography.englishLike.headlineLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineMedium: typography.englishLike.headlineMedium?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineSmall: typography.englishLike.headlineSmall?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      titleLarge: typography.englishLike.titleLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      titleMedium: typography.englishLike.titleMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      titleSmall: typography.englishLike.titleSmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodyLarge: typography.englishLike.bodyLarge?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodyMedium: typography.englishLike.bodyMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodySmall: typography.englishLike.bodySmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelLarge: typography.englishLike.labelLarge?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelMedium: typography.englishLike.labelMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelSmall: typography.englishLike.labelSmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
    ),
    tall: TextTheme(
      displayLarge: typography.tall.displayLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      displayMedium: typography.tall.displayMedium?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      displaySmall: typography.tall.displaySmall?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineLarge: typography.tall.headlineLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineMedium: typography.tall.headlineMedium?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineSmall: typography.tall.headlineSmall?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      titleLarge: typography.tall.titleLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      titleMedium: typography.tall.titleMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      titleSmall: typography.tall.titleSmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodyLarge: typography.tall.bodyLarge?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodyMedium: typography.tall.bodyMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodySmall: typography.tall.bodySmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelLarge: typography.tall.labelLarge?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelMedium: typography.tall.labelMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelSmall: typography.tall.labelSmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
    ),
    white: TextTheme(
      displayLarge: typography.white.displayLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      displayMedium: typography.white.displayMedium?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      displaySmall: typography.white.displaySmall?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineLarge: typography.white.headlineLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineMedium: typography.white.headlineMedium?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      headlineSmall: typography.white.headlineSmall?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      titleLarge: typography.white.titleLarge?.copyWith(
        fontFamily: displayFont,
        color: color,
      ),
      titleMedium: typography.white.titleMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      titleSmall: typography.white.titleSmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodyLarge: typography.white.bodyLarge?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodyMedium: typography.white.bodyMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      bodySmall: typography.white.bodySmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelLarge: typography.white.labelLarge?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelMedium: typography.white.labelMedium?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
      labelSmall: typography.white.labelSmall?.copyWith(
        fontFamily: textFont,
        color: color,
      ),
    ),
    platform: platform,
  );
}
