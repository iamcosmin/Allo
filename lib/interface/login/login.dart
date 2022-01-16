import 'package:allo/components/oobe_page.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Login extends HookConsumerWidget {
  const Login({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = useState('');
    final controller = useTextEditingController();
    final colors = ref.watch(colorsProvider);
    return SetupPage(
      header: const [
        Text(
          'Să ne conectăm...',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Pentru a continua, introdu emailul tău.',
            style: TextStyle(fontSize: 17, color: Colors.grey),
          ),
        ),
      ],
      body: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextFormField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              errorText: error.value == '' ? null : error.value,
              errorStyle: const TextStyle(fontSize: 14),
              labelText: 'Email',
              border: const OutlineInputBorder(),
              fillColor: colors.tileColor,
            ),
            controller: controller,
          ),
        ),
      ],
      onButtonPress: () async {
        await Core.auth.checkAuthenticationAbility(
            email: controller.text.trim(), error: error, context: context);
      },
      isAsync: true,
    );
  }
}
