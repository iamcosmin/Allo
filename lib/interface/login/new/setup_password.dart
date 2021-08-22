import 'package:allo/components/oobe_page.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupPassword extends HookWidget {
  const SetupPassword(
      {required this.displayName, required this.username, required this.email});
  final String displayName;
  final String username;
  final String email;
  @override
  Widget build(BuildContext context) {
    final error = useState('');
    final obscure = useState(true);
    final passController = useTextEditingController();
    final confirmPassController = useTextEditingController();
    final auth = useProvider(Repositories.auth);

    return SetupPage(
      header: [
        Text(
          'Securitatea este importantă.',
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
        ),
        Text(
          'Pentru a crea contul, introdu parola pe care o vrei asociată acestui cont.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  errorText: error.value == '' ? null : error.value,
                  errorStyle: TextStyle(fontSize: 14),
                  labelText: 'Parolă',
                  border: OutlineInputBorder(),
                  suffix: GestureDetector(
                    onTap: () {
                      if (obscure.value) {
                        obscure.value = false;
                      } else {
                        obscure.value = true;
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(
                        obscure.value ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                controller: passController,
                obscureText: obscure.value,
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  errorStyle: TextStyle(fontSize: 14),
                  labelText: 'Confirmă parola',
                  border: OutlineInputBorder(),
                  suffix: GestureDetector(
                    onTap: () {
                      if (obscure.value) {
                        obscure.value = false;
                      } else {
                        obscure.value = true;
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(
                        obscure.value ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                controller: confirmPassController,
                obscureText: obscure.value,
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              Text(
                'Parola ta trebuie să conțină minim 8 caractere, litere mari și mici, cifre, simboluri.',
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ],
      onButtonPress: () async {
        await auth.signUp(
            email: email,
            password: passController.text,
            confirmPassword: confirmPassController.text,
            displayName: displayName,
            username: username,
            error: error,
            context: context);
      },
      isAsync: true,
    );
  }
}
