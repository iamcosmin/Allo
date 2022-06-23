import 'package:flutter/material.dart';

class Motion {
  const Motion();
  final currentVersion = 0.101;
  final animationDuration = const _Duration();
  final animation = const _Animation();
}

class _Duration {
  const _Duration();

  final extraLong1Ms = 700.0;
  final extraLong2Ms = 800.0;
  final extraLong3Ms = 900.0;
  final extraLong4Ms = 1000.0;
  final long1Ms = 450.0;
  final long2Ms = 500.0;
  final long3Ms = 550.0;
  final long4Ms = 600.0;
  final medium1Ms = 250.0;
  final medium2Ms = 300.0;
  final medium3Ms = 350.0;
  final medium4Ms = 400.0;
  final short1Ms = 50.0;
  final short2Ms = 100.0;
  final short3Ms = 150.0;
  final short4Ms = 200.0;
}

class _Animation {
  const _Animation();
  final emphasized = const Cubic(0.2, 0.0, 0.0, 1.0);
  final emphasizedAccelerate = const Cubic(0.3, 0.0, 0.8, 0.15);
  final emphasizedDecelerate = const Cubic(0.05, 0.7, 0.1, 1.0);
  final legacy = const Cubic(0.4, 0.0, 0.2, 1.0);
  final legacyAccelerate = const Cubic(0.4, 0.0, 1.0, 1.0);
  final legacyDecelerate = const Cubic(0.0, 0.0, 0.2, 1.0);
  final linear = const Cubic(0.0, 0.0, 1.0, 1.0);
  final standard = const Cubic(0.2, 0.0, 0.0, 1.0);
  final standardAccelerate = const Cubic(0.3, 0.0, 1.0, 1.0);
  final standardDecelerate = const Cubic(0.0, 0.0, 0.0, 1.0);
}
