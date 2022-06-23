import 'package:allo/components/setup_page.dart';
import 'package:allo/interface/home/tabbed_navigator.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupDone extends HookWidget {
  const SetupDone({super.key});
  @override
  Widget build(BuildContext context) {
    void onSubmit() {
      Navigation.push(route: const TabbedNavigator());
    }

    return SetupPage(
      icon: Icons.check_circle,
      title: Text(context.locale.finishScreenTitle),
      subtitle: Text(context.locale.finishScreenDescription),
      action: onSubmit,
    );
  }
}
