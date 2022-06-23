import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmailNotVerifiedPage extends HookConsumerWidget {
  const EmailNotVerifiedPage({super.key});

  @override
  Widget build(context, ref) {
    return const Scaffold(
      body: Center(
        child: Text('Email not verified.'),
      ),
    );
  }
}
