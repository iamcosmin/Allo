import 'package:allo/components/setup_page.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class VerifyIdentity extends HookWidget {
  /// [VerifyIdentity] is a [Widget] that helps reauthenticating the user in case they
  /// want to change sensible information which requires a recent sign in, such as updating
  /// the password, the email, etc.
  ///
  /// Only use this widget when FirebaseAuth says that it cannot continue without a recent
  /// session connection, using this at every information change will result in a bad
  /// user experience as users want things done fast.
  const VerifyIdentity(this.nextRoute, {super.key});

  /// [nextRoute] is the next [Widget] you want to navigate to if the verification is successful.
  ///
  /// Remember that this pushes as a replacement. This is essential, as we do not want the user
  /// to pop to this route; it may pose a security risk as the password may remain written, so
  /// when an attacker posseses the device, it may change the password.
  final Widget nextRoute;

  @override
  Widget build(context) {
    final error = useState<String?>(null);
    final obscure = useState<bool>(true);
    final focusNode = useFocusNode();
    final controller = useTextEditingController();
    Future<void> onSubmit() async {
      await Core.auth
          .reauthenticate(controller.text, error, context, nextRoute);
    }

    return SetupPage(
      icon: Icons.security_outlined,
      title: Text(context.locale.verifyYourIdentity),
      subtitle: Text(context.locale.enterPasswordDescription),
      body: [
        TextFormField(
          autofillHints: const [AutofillHints.password],
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            errorText: error.value,
            errorStyle: const TextStyle(fontSize: 14),
            labelText: context.locale.password,
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
          autofocus: true,
          focusNode: focusNode,
          controller: controller,
          obscureText: obscure.value,
          onFieldSubmitted: (string) async => onSubmit(),
        ),
      ],
      action: () => onSubmit(),
    );
  }
}
