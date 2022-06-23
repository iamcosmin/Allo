import 'package:allo/components/person_picture.dart';
import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/components/space.dart';
import 'package:allo/interface/home/settings/about.dart';
import 'package:allo/interface/home/settings/account/account.dart';
import 'package:allo/interface/home/settings/debug/account.dart';
import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../components/material3/tile.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = FirebaseAuth.instance.currentUser!.displayName!;
    final newAccountSettings = useSetting(ref, revampedAccountSettingsDebug);
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(context.locale.settings),
      ),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            if (newAccountSettings.setting) ...[
              Card(
                margin: const EdgeInsets.all(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigation.push(route: const AccountSettingsPage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: PersonPicture(
                            radius: 60,
                            profilePicture: Core.auth.user.profilePictureUrl,
                            initials: Core.auth.user.nameInitials,
                          ),
                        ),
                        const Space(
                          0.5,
                          direction: Direction.horizontal,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: context.theme.textTheme.headlineSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 2)),
                            Text(
                              context.locale.customizeYourAccount,
                              style: context.theme.textTheme.labelLarge!
                                  .copyWith(color: context.colorScheme.outline),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              InkWell(
                onTap: () {
                  Navigation.push(route: const OldAccountSettings());
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
                          profilePicture: Core.auth.user.profilePictureUrl,
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
            ],
            const Padding(padding: EdgeInsets.only(top: 10)),
            Tile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(context.locale.personalise),
              onTap: () => Navigation.push(route: const PersonalisePage()),
            ),
            Tile(
              leading: const Icon(Icons.info_outline),
              title: Text(context.locale.about),
              onTap: () => Navigation.push(route: const AboutPage()),
            ),
            Tile(
              leading: const Icon(Icons.logout_rounded),
              title: Text(context.locale.logOut),
              onTap: () async => await Core.auth.signOut(context, ref),
            ),
          ]),
        )
      ],
    );
  }
}
