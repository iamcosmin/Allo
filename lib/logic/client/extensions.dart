import 'package:allo/generated/l10n.dart';
import 'package:flutter/material.dart';

extension Locale on BuildContext {
  S get locale => S.of(this);
}
