import 'package:allo/components/setup_page.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../logic/client/email_validator.dart';

class UpdateEmailPage extends HookConsumerWidget {
  const UpdateEmailPage({super.key});

  @override
  Widget build(context, ref) {
    final error = useState<String?>(null);
    final controller = useTextEditingController();
    Future<void> onSubmit() async {
      await Core.auth.user.updateEmail(controller.text, error, context);
    }

    return SetupPage(
      icon: Icons.email,
      title: const Text('Update Email'),
      subtitle: const Text('Enter a new email you would like to use.'),
      body: [
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            errorText: error.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText: context.loc.email,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onFieldSubmitted: (_) async => await onSubmit(),
          onChanged: (value) {
            if (!EmailValidator.validate(value)) {
              final errorString = context.loc.errorThisIsInvalid(
                context.loc.email.toLowerCase(),
              );
              if (error.value != errorString) {
                error.value = errorString;
              }
            } else {
              if (error.value != null) {
                error.value = null;
              }
            }
          },
          controller: controller,
        ),
      ],
      action: () async => await onSubmit(),
    );
  }
}
