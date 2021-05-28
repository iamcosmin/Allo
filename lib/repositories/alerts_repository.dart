import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final alertsProvider = Provider<AlertsRepository>((ref) => AlertsRepository());

class AlertsRepository {
  void noSuchMethodError(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (context) => Center(
                child: CupertinoActionSheet(
              title: Text('Eroare'),
              message: Text(
                  'Momentan aceasta metoda nu este implementata. Incercati mai tarziu!'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                )
              ],
            )));
  }
}
