import 'package:allo/components/oobe_page.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupUsername extends HookWidget {
  const SetupUsername(
      {required this.displayName, required this.email, Key? key})
      : super(key: key);
  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final error = useState('');
    final auth = useProvider(Repositories.auth);
    return SetupPage(
      header: const [
        Text(
          'Ce nume de utilizator vrei?',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          'Pentru a continua, introdu un numele de utilizator pe care îl dorești.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  prefix: const Text('@'),
                  errorText: error.value == '' ? null : error.value,
                  errorStyle: const TextStyle(fontSize: 14),
                  labelText: 'Nume de utilizator',
                  border: const OutlineInputBorder(),
                ),
                controller: controller,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              const Text(
                'Numele de utilizator este numele unic de identificare \nAcesta trebuie să fie format dintr-o combinație de litere mici, împreună cu underline-uri și puncte sau cifre. Acesta nu trebuie să conțină spații sau diacritice.',
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        )
      ],
      onButtonPress: () async => auth.isUsernameCompliant(
          username: controller.text,
          error: error,
          context: context,
          displayName: displayName,
          email: email),
      isAsync: true,
    );
  }
}
