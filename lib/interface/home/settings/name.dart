import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NameSettings extends HookWidget {
  const NameSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nume')),
    );
  }
}
