import 'package:allo/components/person_picture.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/about.dart';
import 'package:allo/interface/home/settings/account.dart';
import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Settings extends HookConsumerWidget {
  const Settings({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final name = FirebaseAuth.instance.currentUser!.displayName!;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          InkWell(
            onTap: () {
              Core.navigation.push(route: const AccountSettings());
            },
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                  child: PersonPicture(
                    radius: 60,
                    profilePicture: Core.auth.user.profilePicture,
                    initials: Core.auth.user.nameInitials,
                  ),
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
            onTap: () => Core.navigation.push(route: const PersonalisePage()),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(locales.about, style: const TextStyle(fontSize: 18)),
            onTap: () => Core.navigation.push(route: const AboutPage()),
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
