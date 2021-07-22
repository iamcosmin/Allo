import 'package:allo/repositories/preferences_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class C extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final eProfilePic = useProvider(experimentalProfilePicture);
    final eProfilePicMethod = useProvider(experimentalProfilePicture.notifier);
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
                    CupertinoFormRow(
                        prefix: Text('Încarcă fotografie de profil'),
                        child: CupertinoSwitch(
                          value: eProfilePic,
                          onChanged: (value) =>
                              eProfilePicMethod.switcher(context),
                        ))
                  ]),
            ]),
          ))
        ],
      ),
    );
  }
}
