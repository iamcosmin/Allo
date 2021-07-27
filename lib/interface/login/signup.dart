import 'package:allo/components/oobe_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SignupName extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final error = useState('');
    final controller = useTextEditingController();
    return SetupPage(
      header: [
        Text(
          'Cum te numești?',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
        ),
        Text(
          'Pentru a continua, introdu numele tău.',
          style: TextStyle(fontSize: 18, color: CupertinoColors.inactiveGray),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        CupertinoFormSection.insetGrouped(
          children: [
            CupertinoFormRow(
              error: error.value == '' ? null : Text(error.value),
              child: CupertinoTextField(
                decoration: BoxDecoration(color: Colors.transparent),
                placeholder: 'Nume',
                controller: controller,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
      onButtonPress: () {
        print('Coming');
      },
      isAsync: false,
    );
  }
}
