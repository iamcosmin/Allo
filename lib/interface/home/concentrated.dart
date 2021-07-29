import 'package:allo/interface/home/typingbubble.dart';
import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class C extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final navigation = useProvider(Repositories.navigation);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Opțiuni experimentale'),
        previousPageTitle: 'Setări',
      ),
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
              sliver: SliverList(
            delegate: SliverChildListDelegate([
              Padding(padding: EdgeInsets.only(top: 30)),
              CupertinoFormSection.insetGrouped(
                  header: Text(
                      'Aceste opțiuni sunt experimentale și sunt gândite doar pentru testarea internă. Vă rugăm să nu folosiți aceste setări dacă nu știți ce fac.'),
                  children: [
                    GestureDetector(
                      onTap: () => navigation.to(context, ExampleIsTyping()),
                      child: CupertinoFormRow(
                        prefix: Text('Fotografie de profil'),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, right: 5),
                          child: Icon(
                            CupertinoIcons.right_chevron,
                            color: CupertinoColors.systemGrey,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ]),
            ]),
          ))
        ],
      ),
    );
  }
}
