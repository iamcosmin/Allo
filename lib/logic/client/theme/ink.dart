import 'package:allo/components/material3/ink_sparkle.dart';
import 'package:flutter/material.dart';

/// This value is temporary, just until [InkSparkle] arrives into the framework.
InteractiveInkFeatureFactory get inkFeatureHolder {
  final platform = ThemeData().platform;
  if (platform == TargetPlatform.android) {
    return InkSparkle.splashFactory;
  } else {
    return InkSplash.splashFactory;
  }
}
