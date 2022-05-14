import 'package:allo/generated/l10n.dart';
import 'package:flutter/material.dart';

extension EnhancedContext on BuildContext {
  S get locale => S.of(this);
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  NavigatorState get navigator => Navigator.of(this);
}

extension E on int {
  Duration get milliseconds => Duration(milliseconds: this);
  Duration get microseconds => Duration(microseconds: this);
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
  Duration get days => Duration(days: this);
}
