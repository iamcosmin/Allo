import 'package:allo/components/oobe_page.dart';
import 'package:allo/interface/home/tabbed_navigator.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupDone extends HookWidget {
  const SetupDone({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SetupPage(
      icon: Icons.check_circle,
      title: context.locale.finishScreenTitle,
      subtitle: context.locale.finishScreenDescription,
      body: const [],
      action: () async {
        return true;
      },
      isRoutePermanent: true,
      nextRoute: TabbedNavigator(),
    );
  }
}
