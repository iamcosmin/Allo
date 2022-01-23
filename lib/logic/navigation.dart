import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Navigation {
  Future push(
      {required BuildContext context,
      required Widget route,
      bool login = false}) {
    return Navigator.of(context).push(
      login
          ? CupertinoPageRoute(builder: (context) => route)
          : MaterialPageRoute(builder: (context) => route),
    );
  }

  Future pushAndRemoveUntilHome(
      {required BuildContext context, required Widget route}) {
    return Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => route),
      (_) => false,
    );
  }

  Future pushPermanent({required BuildContext context, required Widget route}) {
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => route), (route) => false);
  }
}
