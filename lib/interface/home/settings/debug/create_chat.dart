import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CreateChat extends HookWidget {
  const CreateChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creează o conversație nouă'),
      ),
    );
  }
}
