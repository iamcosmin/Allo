import 'package:flutter/material.dart';

/// Returns a [Typography] element.
/// For Android, the default font will be Google Sans Display and Google Sans Text
/// For the rest of the platforms, the default fonts remain.
/// The typography is strictly in relation with Material 3.
Typography getTypography() {
  final platform = ThemeData().platform;
  String displayFont, textFont;
  switch (platform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      displayFont = 'Display';
      textFont = 'Text';
      break;
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      displayFont = '.SF UI Display';
      textFont = '.SF UI Text';
  }

  final typography = Typography.material2021();
  return Typography(
    black: TextTheme(
      displayLarge:
          typography.black.displayLarge?.copyWith(fontFamily: displayFont),
      displayMedium:
          typography.black.displayMedium?.copyWith(fontFamily: displayFont),
      displaySmall:
          typography.black.displaySmall?.copyWith(fontFamily: displayFont),
      headlineLarge:
          typography.black.headlineLarge?.copyWith(fontFamily: displayFont),
      headlineMedium:
          typography.black.headlineMedium?.copyWith(fontFamily: displayFont),
      headlineSmall:
          typography.black.headlineSmall?.copyWith(fontFamily: displayFont),
      titleLarge:
          typography.black.titleLarge?.copyWith(fontFamily: displayFont),
      titleMedium: typography.black.titleMedium?.copyWith(fontFamily: textFont),
      titleSmall: typography.black.titleSmall?.copyWith(fontFamily: textFont),
      bodyLarge: typography.black.bodyLarge?.copyWith(fontFamily: textFont),
      bodyMedium: typography.black.bodyMedium?.copyWith(fontFamily: textFont),
      bodySmall: typography.black.bodySmall?.copyWith(fontFamily: textFont),
      labelLarge: typography.black.labelLarge?.copyWith(fontFamily: textFont),
      labelMedium: typography.black.labelMedium?.copyWith(fontFamily: textFont),
      labelSmall: typography.black.labelSmall?.copyWith(fontFamily: textFont),
    ),
    dense: TextTheme(
      displayLarge:
          typography.dense.displayLarge?.copyWith(fontFamily: displayFont),
      displayMedium:
          typography.dense.displayMedium?.copyWith(fontFamily: displayFont),
      displaySmall:
          typography.dense.displaySmall?.copyWith(fontFamily: displayFont),
      headlineLarge:
          typography.dense.headlineLarge?.copyWith(fontFamily: displayFont),
      headlineMedium:
          typography.dense.headlineMedium?.copyWith(fontFamily: displayFont),
      headlineSmall:
          typography.dense.headlineSmall?.copyWith(fontFamily: displayFont),
      titleLarge:
          typography.dense.titleLarge?.copyWith(fontFamily: displayFont),
      titleMedium: typography.dense.titleMedium?.copyWith(fontFamily: textFont),
      titleSmall: typography.dense.titleSmall?.copyWith(fontFamily: textFont),
      bodyLarge: typography.dense.bodyLarge?.copyWith(fontFamily: textFont),
      bodyMedium: typography.dense.bodyMedium?.copyWith(fontFamily: textFont),
      bodySmall: typography.dense.bodySmall?.copyWith(fontFamily: textFont),
      labelLarge: typography.dense.labelLarge?.copyWith(fontFamily: textFont),
      labelMedium: typography.dense.labelMedium?.copyWith(fontFamily: textFont),
      labelSmall: typography.dense.labelSmall?.copyWith(fontFamily: textFont),
    ),
    englishLike: TextTheme(
      displayLarge: typography.englishLike.displayLarge
          ?.copyWith(fontFamily: displayFont),
      displayMedium: typography.englishLike.displayMedium
          ?.copyWith(fontFamily: displayFont),
      displaySmall: typography.englishLike.displaySmall
          ?.copyWith(fontFamily: displayFont),
      headlineLarge: typography.englishLike.headlineLarge
          ?.copyWith(fontFamily: displayFont),
      headlineMedium: typography.englishLike.headlineMedium
          ?.copyWith(fontFamily: displayFont),
      headlineSmall: typography.englishLike.headlineSmall
          ?.copyWith(fontFamily: displayFont),
      titleLarge:
          typography.englishLike.titleLarge?.copyWith(fontFamily: displayFont),
      titleMedium:
          typography.englishLike.titleMedium?.copyWith(fontFamily: textFont),
      titleSmall:
          typography.englishLike.titleSmall?.copyWith(fontFamily: textFont),
      bodyLarge:
          typography.englishLike.bodyLarge?.copyWith(fontFamily: textFont),
      bodyMedium:
          typography.englishLike.bodyMedium?.copyWith(fontFamily: textFont),
      bodySmall:
          typography.englishLike.bodySmall?.copyWith(fontFamily: textFont),
      labelLarge:
          typography.englishLike.labelLarge?.copyWith(fontFamily: textFont),
      labelMedium:
          typography.englishLike.labelMedium?.copyWith(fontFamily: textFont),
      labelSmall:
          typography.englishLike.labelSmall?.copyWith(fontFamily: textFont),
    ),
    tall: TextTheme(
      displayLarge:
          typography.tall.displayLarge?.copyWith(fontFamily: displayFont),
      displayMedium:
          typography.tall.displayMedium?.copyWith(fontFamily: displayFont),
      displaySmall:
          typography.tall.displaySmall?.copyWith(fontFamily: displayFont),
      headlineLarge:
          typography.tall.headlineLarge?.copyWith(fontFamily: displayFont),
      headlineMedium:
          typography.tall.headlineMedium?.copyWith(fontFamily: displayFont),
      headlineSmall:
          typography.tall.headlineSmall?.copyWith(fontFamily: displayFont),
      titleLarge: typography.tall.titleLarge?.copyWith(fontFamily: displayFont),
      titleMedium: typography.tall.titleMedium?.copyWith(fontFamily: textFont),
      titleSmall: typography.tall.titleSmall?.copyWith(fontFamily: textFont),
      bodyLarge: typography.tall.bodyLarge?.copyWith(fontFamily: textFont),
      bodyMedium: typography.tall.bodyMedium?.copyWith(fontFamily: textFont),
      bodySmall: typography.tall.bodySmall?.copyWith(fontFamily: textFont),
      labelLarge: typography.tall.labelLarge?.copyWith(fontFamily: textFont),
      labelMedium: typography.tall.labelMedium?.copyWith(fontFamily: textFont),
      labelSmall: typography.tall.labelSmall?.copyWith(fontFamily: textFont),
    ),
    white: TextTheme(
      displayLarge:
          typography.white.displayLarge?.copyWith(fontFamily: displayFont),
      displayMedium:
          typography.white.displayMedium?.copyWith(fontFamily: displayFont),
      displaySmall:
          typography.white.displaySmall?.copyWith(fontFamily: displayFont),
      headlineLarge:
          typography.white.headlineLarge?.copyWith(fontFamily: displayFont),
      headlineMedium:
          typography.white.headlineMedium?.copyWith(fontFamily: displayFont),
      headlineSmall:
          typography.white.headlineSmall?.copyWith(fontFamily: displayFont),
      titleLarge:
          typography.white.titleLarge?.copyWith(fontFamily: displayFont),
      titleMedium: typography.white.titleMedium?.copyWith(fontFamily: textFont),
      titleSmall: typography.white.titleSmall?.copyWith(fontFamily: textFont),
      bodyLarge: typography.white.bodyLarge?.copyWith(fontFamily: textFont),
      bodyMedium: typography.white.bodyMedium?.copyWith(fontFamily: textFont),
      bodySmall: typography.white.bodySmall?.copyWith(fontFamily: textFont),
      labelLarge: typography.white.labelLarge?.copyWith(fontFamily: textFont),
      labelMedium: typography.white.labelMedium?.copyWith(fontFamily: textFont),
      labelSmall: typography.white.labelSmall?.copyWith(fontFamily: textFont),
    ),
    platform: platform,
  );
}
