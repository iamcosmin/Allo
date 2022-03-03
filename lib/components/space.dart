import 'package:flutter/material.dart';

class Space extends StatelessWidget {
  const Space(this.factor, {Key? key}) : super(key: key);
  final double factor;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: factor * 10,
    );
  }
}
