import 'package:allo/components/person_picture.dart';
import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/interface/home/settings/about.dart';
import 'package:allo/interface/home/settings/account.dart';
import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../components/tile.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = FirebaseAuth.instance.currentUser!.displayName!;

    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(context.locale.settings),
      ),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Card(
              margin: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Core.navigation.push(route: const AccountSettings());
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 10,
                        ),
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
                            style: context.theme.textTheme.titleLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Padding(padding: EdgeInsets.only(top: 5)),
                          Text(
                            context.locale.customizeYourAccount,
                            style: const TextStyle(color: Colors.grey),
                          )
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 10))
                    ],
                  ),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            Tile(
              leading: const Icon(Icons.brush),
              title: Text(context.locale.personalise),
              onTap: () => Core.navigation.push(route: const PersonalisePage()),
            ),
            Tile(
              leading: const Icon(Icons.info),
              title: Text(
                context.locale.about,
                style: const TextStyle(fontSize: 18),
              ),
              onTap: () => Core.navigation.push(route: const AboutPage()),
            ),
            Tile(
              leading: const Icon(Icons.logout, size: 27),
              title: Text(
                context.locale.logOut,
                style: const TextStyle(fontSize: 18),
              ),
              onTap: () async => await Core.auth.signOut(context),
            ),
          ]),
        )
      ],
    );
  }
}
