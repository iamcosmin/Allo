import 'package:allo/components/oobe_page.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/progress_rings.dart';
import 'package:allo/components/settings_list.dart';
import 'package:allo/interface/login/new/setup_personalize.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupProfilePicture extends HookWidget {
  const SetupProfilePicture({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final percentage = useState(0.0);
    final loaded = useState(false);
    final navigation = useProvider(Repositories.navigation);
    final auth = useProvider(Repositories.auth);
    return SetupPage(
      header: const [
        Text(
          'Alege o fotografie de profil.',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          'Personalizează contul. Poți sări acest pas dacă dorești.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.left,
        ),
      ],
      body: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 110,
                      width: 110,
                      child: ProgressRing(
                        value: percentage.value,
                      ),
                    ),
                    PersonPicture.determine(
                        radius: 100,
                        profilePicture: auth.user.profilePicture,
                        initials: auth.user.nameInitials),
                  ],
                ),
              ),
              const SettingsListHeader('Gestionează imaginea de profil'),
              SettingsListTile(
                title: 'Încarcă imagine',
                type: RadiusType.BOTH,
                onTap: () async => await auth.user.updateProfilePicture(
                    loaded: loaded,
                    percentage: percentage,
                    context: context,
                    route: const SetupPersonalize()),
              ),
            ],
          ),
        ),
      ],
      onButtonPress: () async {
        await navigation.push(context, const SetupPersonalize());
      },
      isAsync: true,
    );
  }
}
