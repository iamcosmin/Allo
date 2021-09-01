import 'package:allo/components/oobe_page.dart';
import 'package:allo/interface/login/new/setup_username.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupName extends HookWidget {
  const SetupName(this.email, {Key? key}) : super(key: key);
  final String email;
  @override
  Widget build(BuildContext context) {
    final firstFieldError = useState('');
    final secondFieldError = useState('');
    final firstNameController = useTextEditingController();
    final secondNameController = useTextEditingController();
    final nameReg = RegExp(r'^[a-zA-Z]+$');
    final navigation = useProvider(Repositories.navigation);
    return SetupPage(
      header: const [
        Text(
          'Cum te numești?',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          'Pentru a continua, introdu numele tău.',
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
                  errorText: firstFieldError.value == ''
                      ? null
                      : firstFieldError.value,
                  errorStyle: const TextStyle(fontSize: 14),
                  labelText: 'Prenume',
                  border: const OutlineInputBorder(),
                ),
                controller: firstNameController,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  errorText: secondFieldError.value == ''
                      ? null
                      : secondFieldError.value,
                  errorStyle: const TextStyle(fontSize: 14),
                  labelText: 'Nume (opțional)',
                  border: const OutlineInputBorder(),
                ),
                controller: secondNameController,
              ),
            ],
          ),
        ),
      ],
      onButtonPress: () {
        FocusScope.of(context).unfocus();
        firstFieldError.value = '';
        secondFieldError.value = '';
        if (firstNameController.text != '') {
          if (nameReg.hasMatch(firstNameController.text)) {
            if (secondNameController.text != '') {
              if (nameReg.hasMatch(secondNameController.text)) {
                navigation.push(
                  context,
                  SetupUsername(
                    displayName: firstNameController.text +
                        ' ' +
                        secondNameController.text,
                    email: email,
                  ),
                );
              } else {
                secondFieldError.value = 'Numele poate conține doar litere.';
              }
            } else {
              navigation.push(
                context,
                SetupUsername(
                  displayName: firstNameController.text,
                  email: email,
                ),
              );
            }
          } else {
            firstFieldError.value = 'Numele poate conține doar litere.';
          }
        } else {
          firstFieldError.value = 'Numele nu poate fi gol.';
        }
      },
      isAsync: true,
    );
  }
}
