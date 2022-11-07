import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../components/setup_view.dart';

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
        error.value = context.loc.specialCharactersNotAllowed;
      } else {
        error.value = null;
      }
    }

    return SetupView(
      icon: Icons.person,
      title: Text(context.loc.accountChangeNameTitle),
      description: Text(context.loc.accountChangeNameDescription),
      builder: (props) => [
        TextFormField(
          decoration: InputDecoration(
            errorText: firstNameError.value,
            labelText: context.loc.firstName,
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
            errorText: secondNameError.value,
            labelText:
                '${context.loc.lastName} (${context.loc.optional.toLowerCase()})',
          ),
          controller: secondNameController,
          onChanged: (_) {
            validateName(_, secondNameError);
          },
          onFieldSubmitted: (_) => props.callback?.call(),
        ),
      ],
      action: () async {
        final locales = context.loc;
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
      },
    );
  }
}
