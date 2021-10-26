import 'package:allo/components/oobe_page.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EnterPassword extends HookWidget {
  final String email;
  const EnterPassword({required this.email, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final error = useState('');
    final controller = useTextEditingController();
    return SetupPage(
      header: [
        const Text(
          'Bine ai revenit, ',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          '$email!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        const Text(
          'Pentru a continua, introdu parola contului Allo.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
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
              labelText: 'Parola',
              border: const OutlineInputBorder(),
            ),
            controller: controller,
            obscureText: true,
          ),
        ),
      ],
      onButtonPress: () async {
        await Core.auth.signIn(
            email: email,
            password: controller.text,
            context: context,
            error: error);
      },
      isAsync: true,
    );
  }
}
