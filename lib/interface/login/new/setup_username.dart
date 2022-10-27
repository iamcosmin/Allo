import 'package:allo/components/setup_page.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _usernameReg = RegExp(r'^[a-zA-Z0-9_\.]+$');

class SetupUsername extends HookConsumerWidget {
  const SetupUsername({
    super.key,
  });

  @override
  Widget build(context, ref) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final error = useState<String?>(null);

    void onSubmit() async {
      Core.auth.isUsernameCompliant(
        username: controller.text,
        error: error,
        context: context,
        focusNode: focusNode,
        ref: ref,
      );
    }

    return SetupPage(
      icon: Icons.person_search,
      title: Text(context.loc.setupUsernameScreenTitle),
      subtitle: Text(context.loc.setupUsernameScreenDescription),
      body: [
        TextFormField(
          focusNode: focusNode,
          autofocus: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            prefix: const Text('@'),
            errorText: error.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText: context.loc.username,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) {
            if (!_usernameReg.hasMatch(_)) {
              error.value = context.loc.errorThisIsInvalid(
                context.loc.username.toLowerCase(),
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
          context.loc.setupUsernameRequirements,
          style: const TextStyle(color: Colors.grey),
        )
      ],
      action: onSubmit,
    );
  }
}
