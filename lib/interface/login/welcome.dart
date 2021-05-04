import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:allo/components/progress.dart';
import 'package:allo/core/main.dart';
import 'package:allo/interface/login/login.dart';
import 'package:allo/interface/login/signup/signup.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
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
                backgroundColor: Color(0xFF363636),
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
              child: Text('Conectează-te'),
              onPressed: () => Core.navigate.to(context, Login()),
              color: CupertinoTheme.of(context).primaryColor,
            ),
            CupertinoButton(
              child: Text('Nu ai cont? Creează unul!'),
              onPressed: () => Core.navigate.to(context, Signup()),
            )
          ],
        ),
      ),
    );
  }
}
