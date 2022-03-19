import 'package:allo/components/person_picture.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ProfilePictureSettings extends HookWidget {
  const ProfilePictureSettings({Key? key}) : super(key: key);
  static bool loaded = false;
  static bool loading = false;

  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    var loaded = useState(false);
    var percentage = useState(0.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(locales.profilePicture),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: CircularProgressIndicator(
                    value: percentage.value,
                  ),
                ),
                PersonPicture(
                    radius: 150,
                    profilePicture: Core.auth.user.profilePicture,
                    initials: Core.auth.user.nameInitials),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 30)),
          ListTile(
            leading: const Icon(Icons.upgrade_outlined),
            title: Text(locales.changeProfilePicture),
            onTap: () => Core.auth.user.updateProfilePicture(
                loaded: loaded, percentage: percentage, context: context),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 2)),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(locales.deleteProfilePicture),
            onTap: null,
          ),
        ],
      ),
    );
  }
}
