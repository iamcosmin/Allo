import 'package:allo/components/oobe_page.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EnterPassword extends HookWidget {
  final String email;
  const EnterPassword({required this.email});
  @override
  Widget build(BuildContext context) {
    final error = useState('');
    final controller = useTextEditingController();
    final auth = useProvider(Repositories.auth);
    return SetupPage(
      header: [
        Text(
          'Bine ai revenit, ',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          '$email!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
        ),
        Text(
          'Pentru a continua, introdu parola contului Allo.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
      body: [
        Padding(
          padding: EdgeInsets.all(20),
          child: TextFormField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              errorText: error.value == '' ? null : error.value,
              errorStyle: TextStyle(fontSize: 14),
              labelText: 'Parola',
              border: OutlineInputBorder(),
            ),
            controller: controller,
            obscureText: true,
          ),
        ),
      ],
      onButtonPress: () async {
        await auth.signIn(
            email: email,
            password: controller.text,
            context: context,
            error: error);
      },
      isAsync: true,
    );
  }
}
