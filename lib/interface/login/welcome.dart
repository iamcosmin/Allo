import 'package:allo/repositories/repositories.dart';
import 'package:allo/components/progress_rings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:allo/interface/login/login.dart';
import 'package:allo/interface/login/signup/signup.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Welcome extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final navigation = useProvider(Repositories.navigation);
    return CupertinoPageScaffold(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              child: ProgressRing(
                activeColor: CupertinoTheme.of(context).primaryColor,
                value: null,
                strokeWidth: 15,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 35)),
            Center(
              child: Text(
                'Bine ai venit!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 35)),
            CupertinoButton(
              onPressed: () => navigation.to(context, Login()),
              color: CupertinoTheme.of(context).primaryColor,
              child: Text('Conectează-te'),
            ),
            CupertinoButton(
              onPressed: () => navigation.to(context, Signup()),
              child: Text('Nu ai cont? Creează unul!'),
            )
          ],
        ),
      ),
    );
  }
}
