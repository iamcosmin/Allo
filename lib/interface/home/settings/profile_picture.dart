import 'package:allo/components/person_picture.dart';
import 'package:allo/components/settings_list.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:allo/components/progress_rings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: must_be_immutable
class ProfilePictureSettings extends HookWidget {
  ProfilePictureSettings({Key? key}) : super(key: key);
  bool loaded = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var loaded = useState(false);
    var percentage = useState(0.0);
    final auth = useProvider(Repositories.auth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fotografie de profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
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
            type: RadiusType.TOP,
            onTap: () => auth.user.updateProfilePicture(
                loaded: loaded, percentage: percentage, context: context),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 2)),
          const SettingsListTile(
              title: 'Șterge imaginea', type: RadiusType.BOTTOM),
        ],
      ),
    );
  }
}
