import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  const Empty({super.key});

  @override
  Widget build(context) {
    return const SizedBox(
      height: 0,
      width: 0,
      key: ValueKey('ALWAYS_ACTIVE_KEY'),
    );
  }
}
