import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/account/name.dart';
import 'package:allo/interface/home/settings/profile_picture.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../components/slivers/sliver_scaffold.dart';
import '../../../components/tile.dart';

class AccountSettings extends HookWidget {
  const AccountSettings({super.key});
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(locales.account),
      ),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Tile(
              title: Text(
                locales.name,
              ),
              onTap: () {
                Core.navigation.push(
                  route: const ChangeNamePage(),
                );
              },
            ),
            Tile(
              title: Text(
                locales.username,
              ),
            ),
            Tile(
              title: Text(
                locales.profilePicture,
              ),
              onTap: () =>
                  Core.navigation.push(route: const ProfilePictureSettings()),
            )
          ]),
        )
      ],
    );
  }
}
