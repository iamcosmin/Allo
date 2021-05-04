import 'package:flutter/cupertino.dart';

import 'core.dart';

class Alerts extends Core {
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
                  child: Text('OK'),
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context),
                )
              ],
            )));
  }
}
