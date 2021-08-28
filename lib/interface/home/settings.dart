import 'package:allo/components/settings_list.dart';
import 'package:allo/interface/home/concentrated.dart';
import 'package:allo/interface/home/settings/profile_picture.dart';
import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final dark = useProvider(darkMode);
    final auth = useProvider(Repositories.auth);
    final darkMethod = useProvider(darkMode.notifier);
    final name = FirebaseAuth.instance.currentUser!.displayName!;
    // DO NOT REMOVE
    final _a = useState(0);
    void _b() {
      _a.value++;
      if (_a.value == 9) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => C()));
        _a.value = 0;
      }
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, i) => [
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: GestureDetector(onTap: () => _b(), child: Text('Setări')),
              titlePadding: EdgeInsets.only(left: 20, bottom: 15),
            ),
            expandedHeight: 100,
            pinned: true,
          ),
        ],
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: PersonPicture.determine(
                      radius: 100,
                      profilePicture: auth.user.profilePicture,
                      initials: auth.user.nameInitials),
                ),
                Text(name),
                Padding(padding: EdgeInsets.only(bottom: 10))
              ],
            ),
            SettingsListHeader('Cont'),
            SettingsListTile(
              title: 'Fotografie de profil',
              type: RadiusType.BOTH,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePictureSettings(),
                ),
              ),
            ),
            SettingsListHeader('Personalizare'),
            SettingsListTile(
              title: 'Mod întunecat',
              type: RadiusType.BOTH,
              onTap: () => darkMethod.switcher(context),
              trailing: Switch(
                value: dark,
                activeColor: Colors.blue,
                onChanged: (value) => darkMethod.switcher(context),
              ),
            ),
            SettingsListHeader('Gestionare sesiune'),
            SettingsListTile(
              title: 'Deconectare',
              type: RadiusType.BOTH,
              onTap: () async => await auth.signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
