import 'package:allo/components/material3/tile.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/shimmer.dart';
import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/sliver_scroll.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/components/space.dart';
import 'package:allo/interface/home/settings/account/profile_picture.dart';
import 'package:allo/interface/home/settings/account/security/change_email.dart';
import 'package:allo/interface/home/settings/account/security/verify_identity.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../components/tile_card.dart';
import '../../../../logic/core.dart';
import 'name.dart';

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(Core.auth.user.usernameProvider);
    return SScaffold(
      topAppBar: LargeTopAppBar(title: Text(context.loc.account)),
      slivers: [
        SliverScroll(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  PersonPicture(
                    initials: Core.auth.user.nameInitials,
                    profilePicture: Core.auth.user.profilePictureUrl,
                    radius: 120,
                  ),
                  const Space(2),
                  Text(
                    Core.auth.user.name ??
                        (throw Exception('This user has no name. Impossible.')),
                    style: context.theme.textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Space(0.5),
                  username.when(
                    data: (data) {
                      return InkWell(
                        onLongPress: () => Core.stub.showInfoBar(
                          icon: Icons.info_outline,
                          selectableText: true,
                          text: 'UID: ${Core.auth.user.userId}',
                        ),
                        child: Text(
                          '@$data',
                          style: context.theme.textTheme.bodyLarge!.copyWith(
                            color: context.colorScheme.outline,
                          ),
                        ),
                      );
                    },
                    error: (error, stackTrace) => Container(),
                    loading: () {
                      return LoadingContainer(
                        height: context.theme.textTheme.bodyLarge!.fontSize!,
                        width: 100,
                      );
                    },
                  )
                ],
              ),
            ),
            const Space(1),
            const TileHeading('Info'),
            TileCard(
              [
                Tile(
                  leading: const Icon(Icons.perm_identity_outlined),
                  title: Text(context.loc.name),
                  onTap: () {
                    Navigation.forward(
                      const ChangeNamePage(),
                    );
                  },
                ),
                Tile(
                  disabled: true,
                  leading: const Icon(Icons.alternate_email_outlined),
                  title: Text(
                    context.loc.username,
                  ),
                ),
                Tile(
                  leading: const Icon(Icons.image_outlined),
                  title: Text(context.loc.profilePicture),
                  onTap: () => Navigation.forward(
                    const ProfilePictureSettings(),
                  ),
                ),
              ],
            ),
            const TileHeading('Security'),
            TileCard(
              [
                const Tile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text('Privacy'),
                  disabled: true,
                ),
                Tile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  onTap: () => Navigation.forward(
                    const VerifyIdentity(
                      UpdateEmailPage(),
                    ),
                  ),
                ),
                const Tile(
                  leading: Icon(Icons.password_outlined),
                  title: Text('Password'),
                  disabled: true,
                ),
                const Tile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Delete Account'),
                  disabled: true,
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
