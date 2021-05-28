import 'package:allo/repositories/auth_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: must_be_immutable
class Signup extends HookWidget {
  String _name = '';
  String _email = '';
  String _password1 = '';
  String _password2 = '';

  final String errorCode1 = 'Detalii de contact';
  final String errorCode2 = 'Securitate';

  @override
  Widget build(BuildContext context) {
    // ignore: invalid_use_of_protected_member
    final error = useProvider(errorProvider);
    final authProvider = useProvider(Repositories.auth);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 60),
          ),
          Text(
            'Creează un cont nou',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: EdgeInsets.only(top: 60),
          ),
          CupertinoFormSection.insetGrouped(
            header: Text(error != '' ? error : 'Detalii de contact'),
            children: [
              CupertinoTextFormFieldRow(
                placeholder: 'Nume',
                onChanged: (value) => _name = value.trim(),
              ),
              CupertinoTextFormFieldRow(
                placeholder: 'Email',
                onChanged: (value) => _email = value.trim(),
              )
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: Text(error != '' ? error : 'Securitate'),
            children: [
              CupertinoTextFormFieldRow(
                placeholder: 'Parolă',
                onChanged: (value) => _password1 = value,
                obscureText: true,
              ),
              CupertinoTextFormFieldRow(
                placeholder: 'Confirmă parola',
                onChanged: (value) => _password2 = value,
                obscureText: true,
              )
            ],
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: CupertinoButton(
                  onPressed: () => authProvider.signup(
                      _name, _email, _password1, _password2, context),
                  color: CupertinoTheme.of(context).primaryColor,
                  child: Text('Continuă'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
