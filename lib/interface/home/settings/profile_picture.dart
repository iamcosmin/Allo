import 'package:allo/components/person_picture.dart';
import 'package:allo/components/settings_list.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: must_be_immutable
class ProfilePictureSettings extends HookWidget {
  ProfilePictureSettings({Key? key}) : super(key: key);
  bool loaded = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var loaded = useState(false);
    var percentage = useState(0.0);

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
                  child: CircularProgressIndicator(
                    value: percentage.value,
                  ),
                ),
                PersonPicture.determine(
                    radius: 100,
                    profilePicture: Core.auth.user.profilePicture,
                    initials: Core.auth.user.nameInitials),
              ],
            ),
          ),
          const SettingsListHeader('Gestionează imaginea de profil'),
          SettingsListTile(
            title: 'Încarcă imagine',
            type: RadiusType.TOP,
            onTap: () => Core.auth.user.updateProfilePicture(
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
