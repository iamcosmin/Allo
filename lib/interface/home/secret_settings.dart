import 'package:allo/repositories/preferences_repository.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SecretSettings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final dummy = useProvider(dummyParameter).state;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Secret Menu'),
        previousPageTitle: 'Home',
      ),
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
              sliver: SliverList(
            delegate: SliverChildListDelegate([
              Padding(padding: EdgeInsets.only(top: 30)),
              CupertinoFormSection.insetGrouped(children: [
                CupertinoFormRow(
                  prefix: Text('Dark mode'),
                  child: CupertinoSwitch(
                      value: dummy.state,
                      onChanged: (value) {
                        if (dummy.state) {
                          dummy.deactivate(context, 'dummy');
                        } else {
                          dummy.activate(context, 'dummy');
                        }
                      }),
                )
              ]),
            ]),
          ))
        ],
      ),
    );
  }
}
