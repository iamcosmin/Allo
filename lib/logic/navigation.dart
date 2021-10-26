import 'package:flutter/material.dart';

class Navigation {
  Future push({required BuildContext context, required Widget route}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => route),
    );
  }

  Future pushPermanent({required BuildContext context, required Widget route}) {
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => route), (route) => false);
  }
}
