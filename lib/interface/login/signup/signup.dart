import 'package:flutter/cupertino.dart';
import 'package:allo/core/core.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String _name = "";
  String _email = "";
  String _password1 = "";
  String _password2 = "";
  String errorCode1 = "Detalii de contact";
  String errorCode2 = "Securitate";

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
      ),
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
            header: Text(errorCode1),
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
            header: Text(errorCode2),
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
                  child: Text('Continuă'),
                  onPressed: () => Core.auth
                      .signup(_name, _email, _password1, _password2, context)
                      .then((value) => setState(() {
                            errorCode1 = value;
                          })),
                  color: CupertinoTheme.of(context).primaryColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
