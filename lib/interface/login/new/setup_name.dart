import 'package:allo/components/setup_page.dart';
import 'package:allo/interface/login/new/setup_username.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final _nameReg = RegExp(r'^[a-zA-Z]+$');

class SetupName extends HookWidget {
  const SetupName(this.email, {super.key});
  final String email;
  @override
  Widget build(BuildContext context) {
    final firstFieldError = useState<String?>(null);
    final secondFieldError = useState<String?>(null);
    final firstNameController = useTextEditingController();
    final secondNameController = useTextEditingController();
    final focusController = useFocusNode();

    void validateName(String name, ValueNotifier<String?> error) {
      if (name.isNotEmpty && !_nameReg.hasMatch(name)) {
        error.value = context.locale.specialCharactersNotAllowed;
      } else {
        error.value = null;
      }
    }

    void onSubmit() {
      FocusScope.of(context).unfocus();
      if (firstNameController.text.isNotEmpty) {
        if (_nameReg.hasMatch(firstNameController.text)) {
          if (secondNameController.text.isNotEmpty) {
            if (_nameReg.hasMatch(secondNameController.text)) {
              Core.navigation.push(
                route: SetupUsername(
                  displayName:
                      '${firstNameController.text} ${secondNameController.text}',
                  email: email,
                ),
              );
            } else {
              secondFieldError.value =
                  context.locale.specialCharactersNotAllowed;
            }
          } else {
            Core.navigation.push(
              route: SetupUsername(
                displayName: firstNameController.text,
                email: email,
              ),
            );
          }
        } else {
          firstFieldError.value = context.locale.specialCharactersNotAllowed;
        }
      } else {
        firstFieldError.value = context.locale.errorFieldEmpty;
      }
    }

    return SetupPage(
      icon: Icons.person,
      title: Text(context.locale.setupNameScreenTitle),
      subtitle: Text(context.locale.setupNameScreenDescription),
      body: [
        Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                errorText: firstFieldError.value,
                errorStyle: const TextStyle(fontSize: 14),
                labelText: context.locale.firstName,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              onChanged: (_) {
                validateName(_, firstFieldError);
              },
              onFieldSubmitted: (_) {
                validateName(_, firstFieldError);
                if (firstFieldError.value == null) {
                  focusController.requestFocus();
                }
              },
              controller: firstNameController,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            TextFormField(
              focusNode: focusController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                errorText: secondFieldError.value,
                errorStyle: const TextStyle(fontSize: 14),
                labelText: context.locale.lastName,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                validateName(_, secondFieldError);
              },
              onFieldSubmitted: (_) => onSubmit(),
              controller: secondNameController,
            ),
          ],
        ),
      ],
      action: onSubmit,
    );
  }
}
