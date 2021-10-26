import 'package:allo/components/settings_list.dart';
import 'package:allo/interface/home/concentrated.dart';
import 'package:allo/interface/home/settings/profile_picture.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/repositories/preferences_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:allo/components/person_picture.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Settings extends HookWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final dark = useProvider(darkMode);
    final darkMethod = useProvider(darkMode.notifier);
    final name = FirebaseAuth.instance.currentUser!.displayName!;
    // DO NOT REMOVE
    final _a = useState(0);
    void _b() {
      _a.value++;
      if (_a.value == 9) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const C()));
        _a.value = 0;
      }
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, i) => [
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              centerTitle: false,
              title: GestureDetector(
                  onTap: () => _b(),
                  child: Text(
                    'Setări',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).appBarTheme.foregroundColor),
                  )),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
            ),
            expandedHeight: 100,
            pinned: true,
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: PersonPicture.determine(
                      radius: 100,
                      profilePicture: Core.auth.user.profilePicture,
                      initials: Core.auth.user.nameInitials),
                ),
                Text(name),
                const Padding(padding: EdgeInsets.only(bottom: 10))
              ],
            ),
            const SettingsListHeader('Cont'),
            SettingsListTile(
              title: 'Fotografie de profil',
              leading: const Icon(FluentIcons.screen_person_20_filled),
              type: RadiusType.BOTH,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePictureSettings(),
                ),
              ),
            ),
            const SettingsListHeader('Personalizare'),
            SettingsListTile(
              title: 'Culoare de accent',
              type: RadiusType.BOTH,
              leading: const Icon(FluentIcons.paint_bucket_16_filled),
              trailing: DropdownButton(
                value: 'red',
                items: const [
                  DropdownMenuItem(
                    child: Text('Blue'),
                    value: 'blue',
                  ),
                  DropdownMenuItem(child: Text('Red'), value: 'red')
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 5)),
            SettingsListTile(
              title: 'Mod întunecat',
              leading: const Icon(FluentIcons.dark_theme_24_filled),
              type: RadiusType.BOTH,
              onTap: () => darkMethod.switcher(context),
              trailing: Switch(
                value: dark,
                activeColor: Colors.blue,
                onChanged: (value) => darkMethod.switcher(context),
              ),
            ),
            const SettingsListHeader('Gestionare sesiune'),
            SettingsListTile(
              leading: const Icon(FluentIcons.sign_out_20_filled),
              title: 'Deconectare',
              type: RadiusType.BOTH,
              onTap: () async => await Core.auth.signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
