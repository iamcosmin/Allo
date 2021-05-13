import 'package:allo/repositories/auth_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChooseUsername extends HookWidget {
  String _username = "";

  @override
  Widget build(BuildContext context) {
    // ignore: invalid_use_of_protected_member
    final errorCode = useProvider(errorProvider.notifier).state;
    final authProvider = useProvider(Repositories.auth);
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
                onPressed: () =>
                    authProvider.configureUsername(_username, context),
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
