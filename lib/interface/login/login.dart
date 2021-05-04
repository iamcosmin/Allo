import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:allo/core/main.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _email = "";
  String _password = "";
  String error = "";

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
      ),
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
            child: CupertinoFormSection.insetGrouped(
                footer: Text(
                  error,
                  style: TextStyle(color: CupertinoColors.systemYellow),
                ),
                children: [
                  CupertinoTextFormFieldRow(
                    placeholder: 'Email',
                    onChanged: (value) => _email = value.trimRight(),
                    autofillHints: [AutofillHints.email],
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
                    child: Text('Autentificare'),
                    onPressed: () {
                      Core.auth
                          .login(_email, _password, context)
                          .then((value) => setState(() {
                                error = value;
                              }));
                    },
                    color: CupertinoTheme.of(context).primaryColor),
                CupertinoButton(
                  child: Text('Ti-ai uitat parola?'),
                  onPressed: null,
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
