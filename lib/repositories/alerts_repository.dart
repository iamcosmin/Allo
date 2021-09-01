import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final alertsProvider = Provider<AlertsRepository>((ref) => AlertsRepository());

class AlertsRepository {
  void noSuchMethodError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: const Text(
          'Momentan această funcție nu e implementată.',
        ),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}
