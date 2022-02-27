import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/about.dart';
import 'package:allo/interface/home/settings/debug/debug.dart';
import 'package:allo/interface/home/settings/account.dart';
import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Settings extends HookConsumerWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
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
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _b(),
          child: Text(locales.settings),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          InkWell(
            onTap: () {
              Core.navigation
                  .push(context: context, route: const AccountSettings());
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                  child: PersonPicture.determine(
                      radius: 60,
                      profilePicture: Core.auth.user.profilePicture,
                      initials: Core.auth.user.nameInitials),
                ),
                const Padding(padding: EdgeInsets.only(left: 15)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    Text(
                      locales.customizeYourAccount,
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                const Padding(padding: EdgeInsets.only(bottom: 10))
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          ListTile(
            leading: const Icon(Icons.brush),
            title:
                Text(locales.personalise, style: const TextStyle(fontSize: 18)),
            onTap: () => Core.navigation
                .push(context: context, route: const PersonalisePage()),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(locales.about, style: const TextStyle(fontSize: 18)),
            onTap: () => Core.navigation
                .push(context: context, route: const AboutPage()),
          ),
          ListTile(
            leading: const Icon(Icons.logout, size: 27),
            minLeadingWidth: 40,
            title: Text(locales.logOut, style: const TextStyle(fontSize: 18)),
            onTap: () async => await Core.auth.signOut(context),
          ),
        ],
      ),
    );
  }
}
