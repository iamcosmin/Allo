import 'package:allo/logic/client/extensions.dart';
import 'package:flutter/cupertino.dart';

class Validators {
  Validators(this.context);
  final BuildContext context;
  final _nameReg = RegExp(r'^[a-zA-Z]+$');
  String? name(String? name) {
    if (name != null && name.isNotEmpty) {
      if (_nameReg.hasMatch(name)) {
        return null;
      } else {
        return context.loc.specialCharactersNotAllowed;
      }
    } else {
      return context.loc.errorFieldEmpty;
    }
  }
}
