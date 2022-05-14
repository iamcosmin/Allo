import 'package:allo/components/setup_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupPassword extends HookWidget {
  const SetupPassword({
    required this.displayName,
    required this.username,
    required this.email,
    super.key,
  });
  final String displayName;
  final String username;
  final String email;
  @override
  Widget build(BuildContext context) {
    final error = useState<String?>(null);
    final locales = S.of(context);
    final obscure = useState(true);
    final passController = useTextEditingController();
    final confirmPassController = useTextEditingController();
    return SetupPage(
      icon: Icons.password,
      title: Text(context.locale.setupPasswordScreenTitle),
      subtitle: Text(context.locale.setupPasswordScreenDescription),
      body: [
        Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                errorText: error.value,
                errorStyle: const TextStyle(fontSize: 14),
                labelText: locales.password,
                border: const OutlineInputBorder(),
                suffix: Padding(
                  padding: const EdgeInsets.all(5),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: IconButton(
                      iconSize: 25,
                      // ignore: use_named_constants
                      padding: const EdgeInsets.all(0),
                      color: context.colorScheme.primary,
                      icon: obscure.value
                          ? const Icon(
                              Icons.visibility,
                            )
                          : const Icon(
                              Icons.visibility_off,
                            ),
                      onPressed: () => obscure.value = !obscure.value,
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
                suffix: Padding(
                  padding: const EdgeInsets.all(5),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: IconButton(
                      iconSize: 25,
                      // ignore: use_named_constants
                      padding: const EdgeInsets.all(0),
                      color: context.colorScheme.primary,
                      icon: obscure.value
                          ? const Icon(
                              Icons.visibility,
                            )
                          : const Icon(
                              Icons.visibility_off,
                            ),
                      onPressed: () => obscure.value = !obscure.value,
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
      action: () {
        Core.auth.signUp(
          email: email,
          password: passController.text,
          confirmPassword: confirmPassController.text,
          displayName: displayName,
          username: username,
          error: error,
          context: context,
        );
      },
    );
  }
}
