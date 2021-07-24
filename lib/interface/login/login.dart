import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: must_be_immutable
class Login extends HookWidget {
  String _email = '';
  String _password = '';
  RegExp reg = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  Widget build(BuildContext context) {
    // ignore: invalid_use_of_protected_member
    final error = useProvider(errorProvider);
    final auth = useProvider(Repositories.auth);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 100),
          ),
          Text(
            'Conectare',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.only(top: 100),
          ),
          AutofillGroup(
            child: CupertinoFormSection.insetGrouped(children: [
              CupertinoFormRow(
                error: error != '' ? Text(error) : null,
                child: CupertinoTextField(
                  placeholder: 'Email',
                  onChanged: (value) => _email = value.trimRight(),
                  autofillHints: [AutofillHints.email],
                  decoration: BoxDecoration(),
                ),
              ),
              CupertinoTextFormFieldRow(
                placeholder: 'Parola',
                obscureText: true,
                onChanged: (value) => _password = value,
                autofillHints: [AutofillHints.password],
              ),
            ]),
          ),
          Expanded(
              child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                    onPressed: () {
                      auth.login(_email, _password, context);
                    },
                    color: CupertinoTheme.of(context).primaryColor,
                    child: Text('Autentificare')),
                CupertinoButton(
                  onPressed: null,
                  child: Text('Ti-ai uitat parola?'),
                ),
              ],
            ),
          )),
          Padding(padding: EdgeInsets.only(bottom: 5)),
        ],
      ),
    );
  }
}
