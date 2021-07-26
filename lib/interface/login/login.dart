import 'package:allo/components/oobe_page.dart';
import 'package:allo/repositories/repositories.dart' hide Colors;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Login extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final error = useState('');
    final controller = useTextEditingController();
    final auth = useProvider(Repositories.auth);
    return SetupPage(
      header: [
        Text(
          'Să ne conectăm...',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            'Pentru a continua, introdu emailul tău.',
            style: TextStyle(fontSize: 18, color: CupertinoColors.inactiveGray),
          ),
        ),
      ],
      body: [
        CupertinoFormSection.insetGrouped(
          children: [
            CupertinoFormRow(
              error: error.value == '' ? null : Text(error.value),
              child: CupertinoTextField(
                decoration: BoxDecoration(color: Colors.transparent),
                placeholder: 'Email',
                controller: controller,
              ),
            ),
          ],
        ),
      ],
      onButtonPress: () async {
        await auth.checkAuthenticationAbility(
            email: controller.text.trim(), error: error, context: context);
      },
      isAsync: true,
    );
  }
}

class EnterPassword extends HookWidget {
  final String email;
  const EnterPassword({required this.email});
  @override
  Widget build(BuildContext context) {
    final error = useState('');
    final controller = useTextEditingController();
    final auth = useProvider(Repositories.auth);
    return SetupPage(
      header: [
        Text(
          'Bine ai revenit, ',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          '$email!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
        ),
        Text(
          'Pentru a continua, introdu parola contului Allo.',
          style: TextStyle(fontSize: 18, color: CupertinoColors.inactiveGray),
        ),
      ],
      body: [
        CupertinoFormSection.insetGrouped(
          children: [
            CupertinoFormRow(
              error: error.value == '' ? null : Text(error.value),
              child: CupertinoTextField(
                decoration: BoxDecoration(color: Colors.transparent),
                placeholder: 'Parola',
                controller: controller,
                obscureText: true,
              ),
            ),
          ],
        ),
      ],
      onButtonPress: () async {
        await auth.signIn(
            email: email,
            password: controller.text,
            context: context,
            error: error);
      },
      isAsync: true,
    );
  }
}
