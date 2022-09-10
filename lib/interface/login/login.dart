import 'package:allo/components/setup_view.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/existing/enter_password.dart';
import 'package:allo/interface/login/new/setup_name.dart';
import 'package:allo/logic/backend/setup/login.dart';
import 'package:allo/logic/client/email_validator.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});
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
            Navigation.forward(const EnterPassword());
          } else if (!value) {
            Navigation.forward(SetupName(controller.text));
          }
        });
      }
    }

    return SetupView(
      icon: Icons.login,
      title: Text(locales.loginScreenTitle),
      description: Text(locales.loginScreenDescription),
      action: onSubmit,
      builder: (props) {
        return [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              errorText: error.value,
              labelText: locales.email,
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
        ];
      },
    );
  }
}
