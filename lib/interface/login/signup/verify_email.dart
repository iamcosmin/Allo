import 'package:flutter/cupertino.dart';
import 'package:allo/core/core.dart';

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  String errorCode1 =
      'Pentru a confirma contul, accesează emailul trimis de noi.';

  @override
  void initState() {
    super.initState();
    Core.auth.sendEmailVerification();
  }

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
              'Verificare email',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Padding(padding: EdgeInsets.only(top: 60)),
            CupertinoFormSection.insetGrouped(children: [
              CupertinoFormRow(
                child: Text(
                  errorCode1,
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
                      onPressed: () =>
                          Core.auth.isVerified(context).then((value) {
                        setState(() {
                          errorCode1 = value;
                        });
                      }),
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                    CupertinoButton(
                      child: Text('Retrimite emailul'),
                      onPressed: () => Core.auth.sendEmailVerification(),
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
