import 'package:allo/components/oobe_page.dart';
import 'package:allo/repositories/repositories.dart' hide Colors;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupPassword extends HookWidget {
  const SetupPassword(
      {required this.displayName, required this.username, required this.email});
  final String displayName;
  final String username;
  final String email;
  @override
  Widget build(BuildContext context) {
    final error = useState('');
    final obscure = useState(true);
    final passController = useTextEditingController();
    final confirmPassController = useTextEditingController();
    final auth = useProvider(Repositories.auth);

    return SetupPage(
      header: [
        Text(
          'Securitatea este importantă.',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
        ),
        Text(
          'Pentru a crea contul, introdu parola pe care o vrei asociată acestui cont.',
          style: TextStyle(fontSize: 18, color: CupertinoColors.inactiveGray),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        CupertinoFormSection.insetGrouped(
          footer: Text(
              'Parola ta trebuie să conțină: minim 8 caractere, cel puțin o literă mare și una mică, cel puțin o cifră, cel puțin un simbol (!@#\$%^&*(),.?":{}|<>)'),
          children: [
            CupertinoFormRow(
              error: error.value == '' ? null : Text(error.value),
              child: CupertinoTextField(
                decoration: BoxDecoration(color: Colors.transparent),
                placeholder: 'Parolă',
                controller: passController,
                obscureText: obscure.value,
                suffix: GestureDetector(
                  onTap: () {
                    if (obscure.value) {
                      obscure.value = false;
                    } else {
                      obscure.value = true;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(
                      obscure.value
                          ? CupertinoIcons.eye_slash
                          : CupertinoIcons.eye_fill,
                      color: CupertinoColors.systemBackground,
                    ),
                  ),
                ),
              ),
            ),
            CupertinoFormRow(
              child: CupertinoTextField(
                decoration: BoxDecoration(color: Colors.transparent),
                placeholder: 'Confirmă parola',
                controller: confirmPassController,
                obscureText: obscure.value,
                suffix: GestureDetector(
                  onTap: () {
                    if (obscure.value) {
                      obscure.value = false;
                    } else {
                      obscure.value = true;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(
                      obscure.value
                          ? CupertinoIcons.eye_slash
                          : CupertinoIcons.eye_fill,
                      color: CupertinoColors.systemBackground,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
      onButtonPress: () async {
        await auth.signUp(
            email: email,
            password: passController.text,
            confirmPassword: confirmPassController.text,
            displayName: displayName,
            username: username,
            error: error,
            context: context);
      },
      isAsync: true,
    );
  }
}
