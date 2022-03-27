import 'package:flutter/material.dart';

/// Returns a [Typography] element.
/// For Android, the default font will be Google Sans Display and Google Sans Text
/// For the rest of the platforms, the default fonts remain.
/// The typography is strictly in relation with Material 3.
Typography getTypography() {
  final platform = ThemeData().platform;
  switch (platform) {
    case TargetPlatform.android:
      {
        final typography = Typography.material2021();
        return Typography(
          black: TextTheme(
            displayLarge:
                typography.black.displayLarge?.copyWith(fontFamily: 'Display'),
            displayMedium:
                typography.black.displayMedium?.copyWith(fontFamily: 'Display'),
            displaySmall:
                typography.black.displaySmall?.copyWith(fontFamily: 'Display'),
            headlineLarge:
                typography.black.headlineLarge?.copyWith(fontFamily: 'Display'),
            headlineMedium: typography.black.headlineMedium
                ?.copyWith(fontFamily: 'Display'),
            headlineSmall:
                typography.black.headlineSmall?.copyWith(fontFamily: 'Display'),
            titleLarge:
                typography.black.titleLarge?.copyWith(fontFamily: 'Display'),
            titleMedium:
                typography.black.titleMedium?.copyWith(fontFamily: 'Text'),
            titleSmall:
                typography.black.titleSmall?.copyWith(fontFamily: 'Text'),
            bodyLarge: typography.black.bodyLarge?.copyWith(fontFamily: 'Text'),
            bodyMedium:
                typography.black.bodyMedium?.copyWith(fontFamily: 'Text'),
            bodySmall: typography.black.bodySmall?.copyWith(fontFamily: 'Text'),
            labelLarge:
                typography.black.labelLarge?.copyWith(fontFamily: 'Text'),
            labelMedium:
                typography.black.labelMedium?.copyWith(fontFamily: 'Text'),
            labelSmall:
                typography.black.labelSmall?.copyWith(fontFamily: 'Text'),
          ),
          dense: TextTheme(
            displayLarge:
                typography.dense.displayLarge?.copyWith(fontFamily: 'Display'),
            displayMedium:
                typography.dense.displayMedium?.copyWith(fontFamily: 'Display'),
            displaySmall:
                typography.dense.displaySmall?.copyWith(fontFamily: 'Display'),
            headlineLarge:
                typography.dense.headlineLarge?.copyWith(fontFamily: 'Display'),
            headlineMedium: typography.dense.headlineMedium
                ?.copyWith(fontFamily: 'Display'),
            headlineSmall:
                typography.dense.headlineSmall?.copyWith(fontFamily: 'Display'),
            titleLarge:
                typography.dense.titleLarge?.copyWith(fontFamily: 'Display'),
            titleMedium:
                typography.dense.titleMedium?.copyWith(fontFamily: 'Text'),
            titleSmall:
                typography.dense.titleSmall?.copyWith(fontFamily: 'Text'),
            bodyLarge: typography.dense.bodyLarge?.copyWith(fontFamily: 'Text'),
            bodyMedium:
                typography.dense.bodyMedium?.copyWith(fontFamily: 'Text'),
            bodySmall: typography.dense.bodySmall?.copyWith(fontFamily: 'Text'),
            labelLarge:
                typography.dense.labelLarge?.copyWith(fontFamily: 'Text'),
            labelMedium:
                typography.dense.labelMedium?.copyWith(fontFamily: 'Text'),
            labelSmall:
                typography.dense.labelSmall?.copyWith(fontFamily: 'Text'),
          ),
          englishLike: TextTheme(
            displayLarge: typography.englishLike.displayLarge
                ?.copyWith(fontFamily: 'Display'),
            displayMedium: typography.englishLike.displayMedium
                ?.copyWith(fontFamily: 'Display'),
            displaySmall: typography.englishLike.displaySmall
                ?.copyWith(fontFamily: 'Display'),
            headlineLarge: typography.englishLike.headlineLarge
                ?.copyWith(fontFamily: 'Display'),
            headlineMedium: typography.englishLike.headlineMedium
                ?.copyWith(fontFamily: 'Display'),
            headlineSmall: typography.englishLike.headlineSmall
                ?.copyWith(fontFamily: 'Display'),
            titleLarge: typography.englishLike.titleLarge
                ?.copyWith(fontFamily: 'Display'),
            titleMedium: typography.englishLike.titleMedium
                ?.copyWith(fontFamily: 'Text'),
            titleSmall:
                typography.englishLike.titleSmall?.copyWith(fontFamily: 'Text'),
            bodyLarge:
                typography.englishLike.bodyLarge?.copyWith(fontFamily: 'Text'),
            bodyMedium:
                typography.englishLike.bodyMedium?.copyWith(fontFamily: 'Text'),
            bodySmall:
                typography.englishLike.bodySmall?.copyWith(fontFamily: 'Text'),
            labelLarge:
                typography.englishLike.labelLarge?.copyWith(fontFamily: 'Text'),
            labelMedium: typography.englishLike.labelMedium
                ?.copyWith(fontFamily: 'Text'),
            labelSmall:
                typography.englishLike.labelSmall?.copyWith(fontFamily: 'Text'),
          ),
          tall: TextTheme(
            displayLarge:
                typography.tall.displayLarge?.copyWith(fontFamily: 'Display'),
            displayMedium:
                typography.tall.displayMedium?.copyWith(fontFamily: 'Display'),
            displaySmall:
                typography.tall.displaySmall?.copyWith(fontFamily: 'Display'),
            headlineLarge:
                typography.tall.headlineLarge?.copyWith(fontFamily: 'Display'),
            headlineMedium:
                typography.tall.headlineMedium?.copyWith(fontFamily: 'Display'),
            headlineSmall:
                typography.tall.headlineSmall?.copyWith(fontFamily: 'Display'),
            titleLarge:
                typography.tall.titleLarge?.copyWith(fontFamily: 'Display'),
            titleMedium:
                typography.tall.titleMedium?.copyWith(fontFamily: 'Text'),
            titleSmall:
                typography.tall.titleSmall?.copyWith(fontFamily: 'Text'),
            bodyLarge: typography.tall.bodyLarge?.copyWith(fontFamily: 'Text'),
            bodyMedium:
                typography.tall.bodyMedium?.copyWith(fontFamily: 'Text'),
            bodySmall: typography.tall.bodySmall?.copyWith(fontFamily: 'Text'),
            labelLarge:
                typography.tall.labelLarge?.copyWith(fontFamily: 'Text'),
            labelMedium:
                typography.tall.labelMedium?.copyWith(fontFamily: 'Text'),
            labelSmall:
                typography.tall.labelSmall?.copyWith(fontFamily: 'Text'),
          ),
          white: TextTheme(
            displayLarge:
                typography.white.displayLarge?.copyWith(fontFamily: 'Display'),
            displayMedium:
                typography.white.displayMedium?.copyWith(fontFamily: 'Display'),
            displaySmall:
                typography.white.displaySmall?.copyWith(fontFamily: 'Display'),
            headlineLarge:
                typography.white.headlineLarge?.copyWith(fontFamily: 'Display'),
            headlineMedium: typography.white.headlineMedium
                ?.copyWith(fontFamily: 'Display'),
            headlineSmall:
                typography.white.headlineSmall?.copyWith(fontFamily: 'Display'),
            titleLarge:
                typography.white.titleLarge?.copyWith(fontFamily: 'Display'),
            titleMedium:
                typography.white.titleMedium?.copyWith(fontFamily: 'Text'),
            titleSmall:
                typography.white.titleSmall?.copyWith(fontFamily: 'Text'),
            bodyLarge: typography.white.bodyLarge?.copyWith(fontFamily: 'Text'),
            bodyMedium:
                typography.white.bodyMedium?.copyWith(fontFamily: 'Text'),
            bodySmall: typography.white.bodySmall?.copyWith(fontFamily: 'Text'),
            labelLarge:
                typography.white.labelLarge?.copyWith(fontFamily: 'Text'),
            labelMedium:
                typography.white.labelMedium?.copyWith(fontFamily: 'Text'),
            labelSmall:
                typography.white.labelSmall?.copyWith(fontFamily: 'Text'),
          ),
          platform: TargetPlatform.android,
        );
      }
    case TargetPlatform.fuchsia:
      {
        return Typography.material2021(platform: TargetPlatform.fuchsia);
      }
    case TargetPlatform.iOS:
      {
        return Typography.material2021(platform: TargetPlatform.iOS);
      }
    case TargetPlatform.linux:
      {
        return Typography.material2021(platform: TargetPlatform.linux);
      }
    case TargetPlatform.macOS:
      {
        return Typography.material2021(platform: TargetPlatform.macOS);
      }
    case TargetPlatform.windows:
      {
        return Typography.material2021(platform: TargetPlatform.windows);
      }
  }
}
