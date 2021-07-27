import 'package:allo/components/oobe_page.dart';
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
          'Pentru a continua, introdu numele tău.',
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

class SetupUsername extends HookWidget {
  const SetupUsername({required this.displayName, required this.email});
  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final usernameReg = RegExp(r'^[a-zA-Z0-9_\.]+$');
    final controller = useTextEditingController();
    final error = useState('');
    final navigation = useProvider(Repositories.navigation);
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
      onButtonPress: () {
        FocusScope.of(context).unfocus();
        if (controller.text != '') {
          if (usernameReg.hasMatch(controller.text)) {
            navigation.push(
                context,
                SetupPassword(
                  displayName: displayName,
                  username: controller.text,
                  email: email,
                ),
                SharedAxisTransitionType.horizontal);
          } else {
            error.value = 'Numele de utilizator nu este valid.';
          }
        } else {
          error.value = 'Numele de utilizator nu poate fi gol.';
        }
      },
      isAsync: true,
    );
  }
}

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
          'Pentru a continua, introdu parola pe care o vrei asociată acestui cont.',
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
      onButtonPress: () {
        FocusScope.of(context).unfocus();
        if (passController.text != '' && confirmPassController.text != '') {
          if (passController.text == confirmPassController.text) {
            var hasUppercase = passController.text.contains(RegExp(r'[A-Z]'));
            var hasDigits = passController.text.contains(RegExp(r'[0-9]'));
            var hasLowercase = passController.text.contains(RegExp(r'[a-z]'));
            var hasSpecialCharacters =
                passController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
            var hasMinLength = passController.text.length >= 8;
            if (hasUppercase &&
                hasDigits &&
                hasLowercase &&
                hasSpecialCharacters &&
                hasMinLength) {
              auth.signUp(
                  email: email,
                  password: passController.text,
                  displayName: displayName,
                  username: username,
                  error: error,
                  context: context);
            } else {
              error.value = 'Parola ta nu respectă cerințele.';
            }
          } else {
            error.value = 'Parolele nu sunt la fel.';
          }
        } else {
          error.value = 'Parolele nu trebuie să fie goale.';
        }
      },
      isAsync: true,
    );
  }
}
