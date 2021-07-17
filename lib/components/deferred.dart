import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:allo/components/progress_rings.dart';

class Deferred extends HookWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: ProgressRing(),
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            Text(
              'Doar un moment...',
              style: TextStyle(color: Color(0xFF0793FF), fontSize: 18),
            ),
          ],
        ),
      ));
}
