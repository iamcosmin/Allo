import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final loginProvider =
    ChangeNotifierProvider<LoginProvider>((ref) => LoginProvider());

class LoginProvider extends ChangeNotifier {
  String error = "";
  String get getError {
    return error;
  }

  void changeErrorMessage(context, String error) {
    error = error;
    notifyListeners();
  }
}

class Login extends HookWidget {
  String _email = "";
  String _password = "";
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final login = useProvider(loginProvider);
    final auth = useProvider(Repositories.auth);
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
                  login.getError,
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
                      auth.login(_email, _password, context).then(
                          (value) => login.changeErrorMessage(context, value));
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
