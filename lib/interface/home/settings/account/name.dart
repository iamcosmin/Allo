import 'package:allo/components/oobe_page.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChangeNamePage extends HookConsumerWidget {
  const ChangeNamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstNameError = useState('');
    final secondNameError = useState('');
    final firstNameController = useTextEditingController();
    final secondNameController = useTextEditingController();
    final nameReg = RegExp(r'^[a-zA-Z]+$');
    return SetupPage(
      icon: Icons.person,
      title: context.locale.accountChangeNameTitle,
      subtitle: context.locale.accountChangeNameDescription,
      isNavigationHandled: true,
      body: [
        TextFormField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            errorText: firstNameError.value == '' ? null : firstNameError.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText: context.locale.firstName,
            border: const OutlineInputBorder(),
          ),
          controller: firstNameController,
        ),
        const Padding(padding: EdgeInsets.only(bottom: 10)),
        TextFormField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            errorText:
                secondNameError.value == '' ? null : secondNameError.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText: context.locale.lastName +
                ' (${context.locale.optional.toLowerCase()})',
            border: const OutlineInputBorder(),
          ),
          controller: secondNameController,
        ),
      ],
      action: () async {
        final locales = context.locale;
        FocusScope.of(context).unfocus();
        firstNameError.value = '';
        secondNameError.value = '';
        if (firstNameController.text != '') {
          if (nameReg.hasMatch(firstNameController.text)) {
            if (secondNameController.text != '') {
              if (nameReg.hasMatch(secondNameController.text)) {
                FirebaseAuth.instance.currentUser?.updateDisplayName(
                  firstNameController.text + ' ' + secondNameController.text,
                );
                Navigator.of(context).pop();
                return true;
              } else {
                secondNameError.value = locales.specialCharactersNotAllowed;
                return false;
              }
            } else {
              FirebaseAuth.instance.currentUser
                  ?.updateDisplayName(firstNameController.text);
              Navigator.of(context).pop();
              return true;
            }
          } else {
            firstNameError.value = locales.specialCharactersNotAllowed;
            return false;
          }
        } else {
          firstNameError.value = locales.errorFieldEmpty;
          return false;
        }
      },
    );
  }
}
