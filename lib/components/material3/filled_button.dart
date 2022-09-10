import 'package:allo/logic/client/extensions.dart';
import 'package:flutter/material.dart';

ButtonStyle filledButtonStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
    backgroundColor: context.colorScheme.primary,
    foregroundColor: context.colorScheme.onPrimary,
  ).copyWith(
    elevation: const MaterialStatePropertyAll(0.0),
  );
}

ButtonStyle filledTonalButtonStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
    backgroundColor: context.colorScheme.secondaryContainer,
    foregroundColor: context.colorScheme.onSecondaryContainer,
  ).copyWith(
    elevation: const MaterialStatePropertyAll(0.0),
  );
}
