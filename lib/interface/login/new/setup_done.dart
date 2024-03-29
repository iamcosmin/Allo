import 'package:allo/components/setup_page.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

class SetupDone extends HookWidget {
  const SetupDone({super.key});
  @override
  Widget build(BuildContext context) {
    void onSubmit() {
      context.go('/');
    }

    return SetupPage(
      icon: Icons.check_circle,
      title: Text(context.loc.finishScreenTitle),
      subtitle: Text(context.loc.finishScreenDescription),
      action: onSubmit,
    );
  }
}
