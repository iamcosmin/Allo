import 'package:allo/components/setup_view.dart';
import 'package:allo/components/space.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/backend/setup/login.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EnterPassword extends HookConsumerWidget {
  const EnterPassword({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = useState<String?>(null);
    final obscure = useState(true);
    final focusNode = useFocusNode();
    final login = ref.watch(loginState.notifier);
    final state = ref.watch(loginState);
    final controller = useTextEditingController();
    final locales = S.of(context);

    return SetupView(
      icon: Icons.password,
      title: Text('${locales.welcomeBack}.'),
      description: Text(locales.enterPasswordDescription),
      action: () async {
        try {
          await login.login(controller.text);
          Navigation.first();
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case 'user-disabled':
              error.value = locales.errorUserDisabled;
              break;
            case 'wrong-password':
              error.value = locales.errorWrongPassword;
              break;
            case 'too-many-requests':
              error.value = locales.errorTooManyRequests;
              break;
            default:
              error.value = locales.errorUnknown;
              break;
          }
          focusNode.requestFocus();
        } catch (e) {
          error.value = e.toString();
          focusNode.requestFocus();
        }
      },
      builder: (props) => [
        TextFormField(
          autofillHints: const [AutofillHints.password],
          keyboardType: TextInputType.visiblePassword,
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
          autofocus: true,
          focusNode: focusNode,
          controller: controller,
          obscureText: obscure.value,
          onFieldSubmitted: (string) async => props.callback?.call(),
        ),
        const Space(2),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              if (state != null) {
                Core.auth
                    .sendPasswordResetEmail(email: state, context: context);
              } else {
                throw Exception('There is no email in state.');
              }
            },
            child: Text(locales.forgotPassword),
          ),
        )
      ],
    );
  }
}
