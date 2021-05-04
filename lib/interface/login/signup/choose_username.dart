import 'package:flutter/cupertino.dart';
import 'package:allo/core/core.dart';

class ChooseUsername extends StatefulWidget {
  @override
  _ChooseUsernameState createState() => _ChooseUsernameState();
}

class _ChooseUsernameState extends State<ChooseUsername> {
  String _username = "";
  String errorCode = "";

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
      ),
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 60)),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Text(
              'Alege un nume de utilizator',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 60),
          ),
          CupertinoFormSection.insetGrouped(
            footer: Text(
              errorCode,
              style: TextStyle(color: CupertinoColors.systemYellow),
            ),
            children: [
              CupertinoTextFormFieldRow(
                placeholder: 'Nume de utilizator',
                onChanged: (value) => _username = value.trim(),
              )
            ],
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: CupertinoButton(
                child: Text('Aplică'),
                onPressed: () => Core.auth
                    .configureUsername(_username, context)
                    .then((value) {
                  setState(() {
                    errorCode = value;
                  });
                }),
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20))
        ],
      ),
    );
  }
}
