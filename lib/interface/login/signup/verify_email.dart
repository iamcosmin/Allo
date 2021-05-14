import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: must_be_immutable
class VerifyEmail extends HookWidget {
  String errorCode1 =
      'Pentru a confirma contul, accesează emailul trimis de noi.';
  @override
  Widget build(BuildContext context) {
    final auth = useProvider(Repositories.auth);
    // ignore: invalid_use_of_protected_member
    final error = useProvider(errorProvider);
    useEffect(() {
      auth.sendEmailVerification();
    }, const []);
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
              'Verificare email',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Padding(padding: EdgeInsets.only(top: 60)),
            CupertinoFormSection.insetGrouped(children: [
              CupertinoFormRow(
                child: Text(
                  error != "" ? error : errorCode1,
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      child: Text('Am confirmat'),
                      onPressed: () => auth.isVerified(context),
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                    CupertinoButton(
                      child: Text('Retrimite emailul'),
                      onPressed: () => auth.sendEmailVerification(),
                    )
                  ],
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 20))
          ],
        ));
  }
}
