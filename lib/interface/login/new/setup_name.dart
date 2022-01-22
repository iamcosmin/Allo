import 'package:allo/components/oobe_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/new/setup_username.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupName extends HookWidget {
  const SetupName(this.email, {Key? key}) : super(key: key);
  final String email;
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    final firstFieldError = useState('');
    final secondFieldError = useState('');
    final firstNameController = useTextEditingController();
    final secondNameController = useTextEditingController();
    final nameReg = RegExp(r'^[a-zA-Z]+$');
    return SetupPage(
      header: [
        Text(
          locales.setupNameScreenTitle,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          locales.setupNameScreenDescription,
          style: const TextStyle(fontSize: 17, color: Colors.grey),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  errorText: firstFieldError.value == ''
                      ? null
                      : firstFieldError.value,
                  errorStyle: const TextStyle(fontSize: 14),
                  labelText: locales.firstName,
                  border: const OutlineInputBorder(),
                ),
                controller: firstNameController,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  errorText: secondFieldError.value == ''
                      ? null
                      : secondFieldError.value,
                  errorStyle: const TextStyle(fontSize: 14),
                  labelText: locales.lastName,
                  border: const OutlineInputBorder(),
                ),
                controller: secondNameController,
              ),
            ],
          ),
        ),
      ],
      onButtonPress: () {
        FocusScope.of(context).unfocus();
        firstFieldError.value = '';
        secondFieldError.value = '';
        if (firstNameController.text != '') {
          if (nameReg.hasMatch(firstNameController.text)) {
            if (secondNameController.text != '') {
              if (nameReg.hasMatch(secondNameController.text)) {
                Core.navigation.push(
                  context: context,
                  route: SetupUsername(
                    displayName: firstNameController.text +
                        ' ' +
                        secondNameController.text,
                    email: email,
                  ),
                );
              } else {
                secondFieldError.value = locales.specialCharactersNotAllowed;
              }
            } else {
              Core.navigation.push(
                context: context,
                route: SetupUsername(
                  displayName: firstNameController.text,
                  email: email,
                ),
              );
            }
          } else {
            firstFieldError.value = locales.specialCharactersNotAllowed;
          }
        } else {
          firstFieldError.value = locales.errorFieldEmpty;
        }
      },
      isAsync: true,
    );
  }
}
