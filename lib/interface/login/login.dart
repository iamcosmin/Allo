import 'package:allo/components/setup_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/existing/enter_password.dart';
import 'package:allo/interface/login/new/setup_name.dart';
import 'package:allo/logic/backend/setup/login.dart';
import 'package:allo/logic/client/email_validator.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Login extends HookConsumerWidget {
  const Login({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final login = ref.watch(loginState.notifier);
    final error = useState<String?>(null);
    final controller = useTextEditingController();

    void onSubmit() async {
      final isValid = EmailValidator.validate(controller.text);
      if (isValid) {
        await login.checkIfAccountExists(controller.text).then((value) {
          if (value) {
            Core.navigation.push(route: const EnterPassword());
          } else if (!value) {
            Core.navigation.push(route: SetupName(controller.text));
          }
        });
      }
    }

    return SetupPage(
      icon: Icons.login,
      title: Text(locales.loginScreenTitle),
      subtitle: Text(locales.loginScreenDescription),
      body: [
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            errorText: error.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText: locales.email,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onFieldSubmitted: (_) async => onSubmit(),
          onChanged: (value) {
            if (!EmailValidator.validate(value)) {
              final errorString = context.locale.errorThisIsInvalid(
                context.locale.email.toLowerCase(),
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
      action: onSubmit,
    );
  }
}
