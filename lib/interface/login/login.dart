import 'package:allo/components/oobe_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Login extends HookConsumerWidget {
  const Login({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final error = useState('');
    final controller = useTextEditingController();
    return SetupPage(
      icon: Icons.login,
      title: locales.loginScreenTitle,
      subtitle: locales.loginScreenDescription,
      body: [
        TextFormField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            errorText: error.value == '' ? null : error.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText: locales.email,
            border: const OutlineInputBorder(),
          ),
          controller: controller,
        ),
      ],
      isNavigationHandled: true,
      action: () async {
        return await Core.auth.checkAuthenticationAbility(
            email: controller.text.trim(), error: error, context: context);
      },
    );
  }
}
