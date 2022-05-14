import 'package:allo/components/setup_page.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final _usernameReg = RegExp(r'^[a-zA-Z0-9_\.]+$');

class SetupUsername extends HookWidget {
  const SetupUsername({
    required this.displayName,
    required this.email,
    super.key,
  });
  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final error = useState<String?>(null);

    void onSubmit() async {
      Core.auth.isUsernameCompliant(
        username: controller.text,
        error: error,
        context: context,
        displayName: displayName,
        email: email,
        focusNode: focusNode,
      );
    }

    return SetupPage(
      icon: Icons.person_search,
      title: Text(context.locale.setupUsernameScreenTitle),
      subtitle: Text(context.locale.setupUsernameScreenDescription),
      body: [
        TextFormField(
          focusNode: focusNode,
          autofocus: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            prefix: const Text('@'),
            errorText: error.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText: context.locale.username,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) {
            if (!_usernameReg.hasMatch(_)) {
              error.value = context.locale.errorThisIsInvalid(
                context.locale.username.toLowerCase(),
              );
            } else {
              error.value = null;
            }
          },
          onFieldSubmitted: (_) => onSubmit(),
          controller: controller,
        ),
        const Padding(padding: EdgeInsets.only(bottom: 10)),
        Text(
          context.locale.setupUsernameRequirements,
          style: const TextStyle(color: Colors.grey),
        )
      ],
      action: onSubmit,
    );
  }
}
