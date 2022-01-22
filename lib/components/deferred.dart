import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Deferred extends HookWidget {
  const Deferred({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Scaffold(
        body: Center(
          child: SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
