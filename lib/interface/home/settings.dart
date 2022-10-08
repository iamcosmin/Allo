import 'package:allo/components/person_picture.dart';
import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/components/space.dart';
import 'package:allo/components/tile_card.dart';
import 'package:allo/logic/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../components/material3/tile.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = FirebaseAuth.instance.currentUser!.displayName!;
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(context.loc.settings),
      ),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              TileCard([
                InkWell(
                  onTap: () => context.go('/settings/account'),
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
                              style: context.textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 2)),
                            Text(
                              context.loc.customizeYourAccount,
                              style: context.textTheme.labelLarge!.copyWith(
                                color: context.colorScheme.outline,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              TileCard(
                [
                  Tile(
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(context.loc.personalise),
                    onTap: () => context.go('/settings/personalise'),
                  ),
                  Tile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(context.loc.about),
                    onTap: () => context.go('/settings/about'),
                  ),
                  Tile(
                    leading: const Icon(Icons.logout_rounded),
                    title: Text(context.loc.logOut),
                    onTap: () async => await Core.auth.signOut(ref),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
