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
      icon: Icons.person,
      title: locales.setupNameScreenTitle,
      subtitle: locales.setupNameScreenDescription,
      body: [
        Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                errorText:
                    firstFieldError.value == '' ? null : firstFieldError.value,
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
      ],
      isNavigationHandled: true,
      action: () async {
        FocusScope.of(context).unfocus();
        firstFieldError.value = '';
        secondFieldError.value = '';
        if (firstNameController.text != '') {
          if (nameReg.hasMatch(firstNameController.text)) {
            if (secondNameController.text != '') {
              if (nameReg.hasMatch(secondNameController.text)) {
                Core.navigation.push(
                  route: SetupUsername(
                    displayName:
                        '${firstNameController.text} ${secondNameController.text}',
                    email: email,
                  ),
                );
                return true;
              } else {
                secondFieldError.value = locales.specialCharactersNotAllowed;
                return false;
              }
            } else {
              Core.navigation.push(
                route: SetupUsername(
                  displayName: firstNameController.text,
                  email: email,
                ),
              );
              return true;
            }
          } else {
            firstFieldError.value = locales.specialCharactersNotAllowed;
            return false;
          }
        } else {
          firstFieldError.value = locales.errorFieldEmpty;
          return false;
        }
      },
    );
  }
}
