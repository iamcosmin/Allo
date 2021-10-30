import 'package:allo/interface/home/settings/profile_picture.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AccountSettings extends HookWidget {
  const AccountSettings({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final firstNameError = useState('');
    final secondNameError = useState('');
    final firstNameController = useTextEditingController();
    final secondNameController = useTextEditingController();
    final nameReg = RegExp(r'^[a-zA-Z]+$');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cont'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text(
              'Nume',
              style: TextStyle(fontSize: 18),
            ),
            minLeadingWidth: 20,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Schimbă numele'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Introdu numele nou mai jos.'),
                      const Padding(padding: EdgeInsets.only(top: 20)),
                      TextFormField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          errorText: firstNameError.value == ''
                              ? null
                              : firstNameError.value,
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
                          errorText: secondNameError.value == ''
                              ? null
                              : secondNameError.value,
                          errorStyle: const TextStyle(fontSize: 14),
                          labelText: 'Nume (opțional)',
                          border: const OutlineInputBorder(),
                        ),
                        controller: secondNameController,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Anulare'),
                    ),
                    TextButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        firstNameError.value = '';
                        secondNameError.value = '';
                        if (firstNameController.text != '') {
                          if (nameReg.hasMatch(firstNameController.text)) {
                            if (secondNameController.text != '') {
                              if (nameReg.hasMatch(secondNameController.text)) {
                                FirebaseAuth.instance.currentUser
                                    ?.updateDisplayName(
                                  firstNameController.text +
                                      ' ' +
                                      secondNameController.text,
                                );
                                Navigator.of(context).pop();
                              } else {
                                secondNameError.value =
                                    'Numele poate conține doar litere.';
                              }
                            } else {
                              FirebaseAuth.instance.currentUser
                                  ?.updateDisplayName(firstNameController.text);
                              Navigator.of(context).pop();
                            }
                          } else {
                            firstNameError.value =
                                'Numele poate conține doar litere.';
                          }
                        } else {
                          firstNameError.value = 'Numele nu poate fi gol.';
                        }
                      },
                      child: const Text('Schimbă'),
                    ),
                  ],
                ),
              );
            },
          ),
          const ListTile(
            title: Text(
              'Nume de utilizator',
              style: TextStyle(fontSize: 18),
            ),
          ),
          ListTile(
            title: const Text(
              'Fotografie de profil',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () => Core.navigation
                .push(context: context, route: ProfilePictureSettings()),
          )
        ],
      ),
    );
  }
}
