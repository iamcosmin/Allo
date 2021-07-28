import 'package:allo/components/oobe_page.dart';
import 'package:allo/interface/login/new/setup_username.dart';
import 'package:allo/repositories/repositories.dart' hide Colors;
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupName extends HookWidget {
  const SetupName(this.email);
  final String email;
  @override
  Widget build(BuildContext context) {
    final firstFieldError = useState('');
    final secondFieldError = useState('');
    final firstNameController = useTextEditingController();
    final secondNameController = useTextEditingController();
    final nameReg = RegExp(r'^[a-zA-Z]+$');
    final navigation = useProvider(Repositories.navigation);
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
          'Pentru a continua, introdu numele tău. \nContinuând, ești de acord să creezi un cont nou.',
          style: TextStyle(fontSize: 18, color: CupertinoColors.inactiveGray),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        CupertinoFormSection.insetGrouped(
          children: [
            CupertinoFormRow(
              error: firstFieldError.value == ''
                  ? null
                  : Text(firstFieldError.value),
              child: CupertinoTextField(
                decoration: BoxDecoration(color: Colors.transparent),
                placeholder: 'Prenume',
                controller: firstNameController,
                obscureText: false,
              ),
            ),
            CupertinoFormRow(
              error: secondFieldError.value == ''
                  ? null
                  : Text(secondFieldError.value),
              child: CupertinoTextField(
                decoration: BoxDecoration(color: Colors.transparent),
                placeholder: 'Nume (opțional)',
                controller: secondNameController,
                obscureText: false,
              ),
            ),
          ],
        ),
      ],
      onButtonPress: () {
        FocusScope.of(context).unfocus();
        if (firstNameController.text != '') {
          if (nameReg.hasMatch(firstNameController.text)) {
            if (secondNameController.text != '') {
              if (nameReg.hasMatch(secondNameController.text)) {
                navigation.push(
                    context,
                    SetupUsername(
                      displayName: firstNameController.text +
                          ' ' +
                          secondNameController.text,
                      email: email,
                    ),
                    SharedAxisTransitionType.horizontal);
              } else {
                secondFieldError.value = 'Numele poate conține doar litere.';
              }
            } else {
              navigation.push(
                  context,
                  SetupUsername(
                    displayName: firstNameController.text,
                    email: email,
                  ),
                  SharedAxisTransitionType.horizontal);
            }
          } else {
            firstFieldError.value = 'Numele poate conține doar litere.';
          }
        } else {
          firstFieldError.value = 'Numele nu poate fi gol.';
        }
      },
      isAsync: true,
    );
  }
}
