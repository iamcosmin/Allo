import 'package:allo/components/space.dart';
import 'package:flutter/material.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    required this.text,
    this.icon,
    super.key,
  });
  final Icon? icon;
  final String text;

  @override
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon ??
            const Icon(
              Icons.info_outline,
              size: 40,
            ),
        const Space(1),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        )
      ],
    );
  }
}
