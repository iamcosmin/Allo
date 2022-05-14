import 'package:allo/components/setup_page.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _nameReg = RegExp(r'^[a-zA-Z]+$');

class ChangeNamePage extends HookConsumerWidget {
  const ChangeNamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstNameError = useState<String?>(null);
    final secondNameError = useState<String?>(null);
    final firstNameController = useTextEditingController();
    final secondNameController = useTextEditingController();

    void validateName(String name, ValueNotifier<String?> error) {
      if (name.isNotEmpty && !_nameReg.hasMatch(name)) {
        error.value = context.locale.specialCharactersNotAllowed;
      } else {
        error.value = null;
      }
    }

    void onSubmit() async {
      final locales = context.locale;
      FocusScope.of(context).unfocus();
      firstNameError.value = null;
      secondNameError.value = null;
      if (firstNameController.text != '') {
        if (_nameReg.hasMatch(firstNameController.text)) {
          if (secondNameController.text != '') {
            if (_nameReg.hasMatch(secondNameController.text)) {
              await FirebaseAuth.instance.currentUser?.updateDisplayName(
                '${firstNameController.text} ${secondNameController.text}',
              );
              context.navigator.pop();
            } else {
              secondNameError.value = locales.specialCharactersNotAllowed;
            }
          } else {
            await FirebaseAuth.instance.currentUser
                ?.updateDisplayName(firstNameController.text);
            context.navigator.pop();
          }
        } else {
          firstNameError.value = locales.specialCharactersNotAllowed;
        }
      } else {
        firstNameError.value = locales.errorFieldEmpty;
      }
    }

    return SetupPage(
      icon: Icons.person,
      title: Text(context.locale.accountChangeNameTitle),
      body: [
        TextFormField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            errorText: firstNameError.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText: context.locale.firstName,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          controller: firstNameController,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            validateName(_, firstNameError);
          },
        ),
        const Padding(padding: EdgeInsets.only(bottom: 10)),
        TextFormField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            errorText: secondNameError.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText:
                '${context.locale.lastName} (${context.locale.optional.toLowerCase()})',
            border: const OutlineInputBorder(),
          ),
          controller: secondNameController,
          onChanged: (_) {
            validateName(_, secondNameError);
          },
          onFieldSubmitted: (_) async => onSubmit(),
        ),
      ],
      actionText: context.locale.finish,
      action: () async => onSubmit(),
    );
  }
}
