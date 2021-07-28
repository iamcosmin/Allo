import 'package:allo/components/oobe_page.dart';
import 'package:allo/repositories/repositories.dart' hide Colors;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupUsername extends HookWidget {
  const SetupUsername({required this.displayName, required this.email});
  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final error = useState('');
    final auth = useProvider(Repositories.auth);
    return SetupPage(
      header: [
        Text(
          'Ce nume de utilizator vrei?',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
        ),
        Text(
          'Pentru a continua, introdu un numele de utilizator pe care îl dorești.',
          style: TextStyle(fontSize: 18, color: CupertinoColors.inactiveGray),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        CupertinoFormSection.insetGrouped(
          footer: Text(
              'Numele de utilizator este numele unic de identificare \nAcesta trebuie să fie format dintr-o combinație de litere mici, împreună cu underline-uri și puncte sau cifre. Acesta nu trebuie să conțină spații sau diacritice. '),
          children: [
            CupertinoFormRow(
              error: error.value == '' ? null : Text(error.value),
              child: CupertinoTextField(
                prefix: Text('@'),
                decoration: BoxDecoration(color: Colors.transparent),
                placeholder: 'Nume de utilizator',
                controller: controller,
                obscureText: false,
              ),
            ),
          ],
        )
      ],
      onButtonPress: () async => auth.checkUsernameInSignUp(
          username: controller.text,
          error: error,
          context: context,
          displayName: displayName,
          email: email),
      isAsync: true,
    );
  }
}
