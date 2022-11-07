import 'package:allo/components/setup_view.dart';
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

    return SetupView(
      title: Text(context.loc.verifyYourIdentity),
      description: Text(context.loc.enterPasswordDescription),
      builder: (props) => [
        TextFormField(
          autofillHints: const [AutofillHints.password],
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            errorText: error.value,
            labelText: context.loc.password,
            suffix: SizedBox.square(
              dimension: 28,
              child: IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                // ignore: use_named_constants
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
          autofocus: true,
          focusNode: focusNode,
          controller: controller,
          obscureText: obscure.value,
          onFieldSubmitted: (_) => props.callback?.call(),
        ),
      ],
      action: () async {
        await Core.auth
            .reauthenticate(controller.text, error, context, nextRoute);
      },
    );
  }
}
