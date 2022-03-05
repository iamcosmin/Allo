import 'package:allo/components/oobe_page.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupUsername extends HookWidget {
  const SetupUsername(
      {required this.displayName, required this.email, Key? key})
      : super(key: key);
  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    final controller = useTextEditingController();
    final error = useState('');
    return SetupPage(
      icon: Icons.person_search,
      title: context.locale.setupUsernameScreenTitle,
      subtitle: context.locale.setupUsernameScreenDescription,
      body: [
        Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                prefix: const Text('@'),
                errorText: error.value == '' ? null : error.value,
                errorStyle: const TextStyle(fontSize: 14),
                labelText: locales.username,
                border: const OutlineInputBorder(),
              ),
              controller: controller,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            Text(
              locales.setupUsernameRequirements,
              style: const TextStyle(color: Colors.grey),
            )
          ],
        )
      ],
      action: () async => await Core.auth.isUsernameCompliant(
        username: controller.text,
        error: error,
        context: context,
        displayName: displayName,
        email: email,
      ),
      isNavigationHandled: true,
    );
  }
}
