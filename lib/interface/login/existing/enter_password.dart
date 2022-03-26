import 'package:allo/components/oobe_page.dart';
import 'package:allo/components/space.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/tabbed_navigator.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EnterPassword extends HookWidget {
  final String email;
  const EnterPassword({required this.email, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final error = useState('');
    final obscure = useState(true);
    final controller = useTextEditingController();
    final locales = S.of(context);
    return SetupPage(
      alignment: CrossAxisAlignment.start,
      icon: Icons.password,
      title: '${locales.welcomeBack}.',
      subtitle: locales.enterPasswordDescription,
      body: [
        TextFormField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            errorText: error.value == '' ? null : error.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText: locales.password,
            border: const OutlineInputBorder(),
            suffix: InkWell(
              onTap: () {
                if (obscure.value) {
                  obscure.value = false;
                } else {
                  obscure.value = true;
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(
                  obscure.value ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          controller: controller,
          obscureText: true,
        ),
        const Space(2),
        TextButton(
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            alignment: Alignment.topLeft,
          ),
          onPressed: () {
            Core.auth.sendPasswordResetEmail(email: email, context: context);
          },
          child: Text(locales.forgotPassword),
        )
      ],
      action: () async {
        return await Core.auth.signIn(
          email: email,
          password: controller.text,
          context: context,
          error: error,
        );
      },
      nextRoute: TabbedNavigator(),
      isRoutePermanent: true,
    );
  }
}
