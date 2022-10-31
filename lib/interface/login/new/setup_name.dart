import 'package:allo/components/setup_page.dart';
import 'package:allo/logic/backend/setup/login.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _nameReg = RegExp(r'^[a-zA-Z]+$');

class SetupName extends HookConsumerWidget {
  const SetupName({super.key});
  @override
  Widget build(BuildContext context, ref) {
    final firstFieldError = useState<String?>(null);
    final secondFieldError = useState<String?>(null);
    final firstNameController = useTextEditingController();
    final secondNameController = useTextEditingController();
    void validateName(String name, ValueNotifier<String?> error) {
      if (name.isNotEmpty && !_nameReg.hasMatch(name)) {
        error.value = context.loc.specialCharactersNotAllowed;
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
              ref.read(signupState.notifier).addName(
                    '${firstNameController.text} ${secondNameController.text}',
                  );
              context.go('/start/signup/username');
            } else {
              secondFieldError.value = context.loc.specialCharactersNotAllowed;
            }
          } else {
            ref.read(signupState.notifier).addName(firstNameController.text);
            context.go('/start/signup/username');
          }
        } else {
          firstFieldError.value = context.loc.specialCharactersNotAllowed;
        }
      } else {
        firstFieldError.value = context.loc.errorFieldEmpty;
      }
    }

    return SetupPage(
      icon: Icons.person,
      title: Text(context.loc.setupNameScreenTitle),
      subtitle: Text(context.loc.setupNameScreenDescription),
      body: [
        Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                errorText: firstFieldError.value,
                errorStyle: const TextStyle(fontSize: 14),
                labelText: context.loc.firstName,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                validateName(_, firstFieldError);
              },
              controller: firstNameController,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            TextFormField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                errorText: secondFieldError.value,
                errorStyle: const TextStyle(fontSize: 14),
                labelText: context.loc.lastName,
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
