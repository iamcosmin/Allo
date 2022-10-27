import 'package:allo/components/person_picture.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/logic/core.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:flutter/material.dart' hide SliverAppBar;
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../components/slivers/sliver_scaffold.dart';

class ProfilePictureSettings extends HookWidget {
  const ProfilePictureSettings({super.key});
  static bool loaded = false;
  static bool loading = false;

  @override
  Widget build(BuildContext context) {
    final percentage = useState(0.0);

    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(context.loc.profilePicture),
      ),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: ProgressRing(
                      value: percentage.value,
                    ),
                  ),
                  PersonPicture(
                    radius: 150,
                    profilePicture: Core.auth.user.profilePictureUrl,
                    initials: Core.auth.user.nameInitials,
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 30)),
            ListTile(
              leading: const Icon(Icons.upgrade_outlined),
              title: Text(context.loc.changeProfilePicture),
              onTap: () => Core.auth.user.updateProfilePicture(
                percentage: percentage,
                context: context,
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 2)),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(context.loc.deleteProfilePicture),
              onTap: () async =>
                  await Core.auth.user.deleteProfilePicture(context: context),
            ),
          ]),
        )
      ],
    );
  }
}
