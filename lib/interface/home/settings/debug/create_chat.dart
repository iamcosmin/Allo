import 'package:allo/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CreateChat extends HookWidget {
  const CreateChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.createNewChat),
      ),
    );
  }
}
