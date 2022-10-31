import 'package:allo/components/setup_page.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../logic/backend/setup/login.dart';

class SetupPassword extends HookConsumerWidget {
  const SetupPassword({
    super.key,
  });
  @override
  Widget build(context, ref) {
    final error = useState<String?>(null);
    final obscure = useState(true);
    final passController = useTextEditingController();
    final confirmPassController = useTextEditingController();

    void onSubmit() {
      final state = ref.read(signupState);
      Core.auth.signUp(
        email: state.email!,
        password: passController.text,
        confirmPassword: confirmPassController.text,
        displayName: state.name!,
        username: state.username!,
        error: error,
        context: context,
      );
    }

    return SetupPage(
      icon: Icons.password,
      title: Text(context.loc.setupPasswordScreenTitle),
      subtitle: Text(context.loc.setupPasswordScreenDescription),
      body: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              errorText: error.value,
              errorStyle: const TextStyle(fontSize: 14),
              labelText: context.loc.password,
              border: const OutlineInputBorder(),
              suffix: Padding(
                padding: const EdgeInsets.all(5),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: ExcludeFocus(
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
            ),
            controller: passController,
            obscureText: obscure.value,
          ),
        ),
        TextFormField(
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            errorStyle: const TextStyle(fontSize: 14),
            labelText: context.loc.confirmPassword,
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
          context.loc.passwordCriteria,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
      action: () => onSubmit(),
    );
  }
}
