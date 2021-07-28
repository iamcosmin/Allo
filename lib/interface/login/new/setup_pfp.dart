import 'package:allo/components/oobe_page.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/progress_rings.dart';
import 'package:allo/interface/login/new/setup_personalize.dart';
import 'package:allo/repositories/repositories.dart' hide Colors;
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupProfilePicture extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final percentage = useState(0.0);
    final loaded = useState(false);
    final navigation = useProvider(Repositories.navigation);
    final auth = useProvider(Repositories.auth);
    return SetupPage(
      header: [
        Text(
          'Alege o fotografie de profil.',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
        ),
        Text(
          'Personalizează contul. Poți sări acest pas dacă dorești.',
          style: TextStyle(fontSize: 18, color: CupertinoColors.inactiveGray),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        CupertinoFormSection.insetGrouped(
          children: [
            CupertinoFormRow(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 110,
                      width: 110,
                      child: ProgressRing(
                        value: percentage.value,
                      ),
                    ),
                    PersonPicture.determine(
                        radius: 100,
                        profilePicture: auth.returnProfilePicture(),
                        initials: auth.returnAuthenticatedNameInitials()),
                  ],
                ),
              ),
            )
          ],
        ),
        CupertinoFormSection.insetGrouped(
          header: Text('Gestionează imaginea de profil'),
          children: [
            GestureDetector(
              onTap: () async => await auth.updateProfilePicture(
                  loaded: loaded,
                  percentage: percentage,
                  context: context,
                  route: SetupPersonalize()),
              child: CupertinoFormRow(
                prefix: Text('Încarcă imagine'),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5),
                  child: Icon(
                    CupertinoIcons.right_chevron,
                    color: CupertinoColors.systemGrey,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
      onButtonPress: () async {
        await navigation.push(
            context, SetupPersonalize(), SharedAxisTransitionType.horizontal);
      },
      isAsync: true,
    );
  }
}
