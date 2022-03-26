import 'package:allo/components/oobe_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/new/setup_verification.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupPassword extends HookWidget {
  const SetupPassword({
    required this.displayName,
    required this.username,
    required this.email,
    Key? key,
  }) : super(key: key);
  final String displayName;
  final String username;
  final String email;
  @override
  Widget build(BuildContext context) {
    final error = useState('');
    final locales = S.of(context);
    final obscure = useState(true);
    final passController = useTextEditingController();
    final confirmPassController = useTextEditingController();
    return SetupPage(
      icon: Icons.password,
      title: context.locale.setupPasswordScreenTitle,
      subtitle: context.locale.setupPasswordScreenDescription,
      body: [
        Column(
          children: [
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
              controller: passController,
              obscureText: obscure.value,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            TextFormField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                errorStyle: const TextStyle(fontSize: 14),
                labelText: locales.confirmPassword,
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
              controller: confirmPassController,
              obscureText: obscure.value,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            Text(
              locales.passwordCriteria,
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ),
      ],
      action: () async {
        return await Core.auth.signUp(
          email: email,
          password: passController.text,
          confirmPassword: confirmPassController.text,
          displayName: displayName,
          username: username,
          error: error,
          context: context,
        );
      },
      nextRoute: const SetupVerification(),
    );
  }
}
