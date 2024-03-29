import 'package:allo/components/person_picture.dart';
import 'package:allo/components/setup_page.dart';
import 'package:allo/interface/login/new/setup_personalize.dart';
import 'package:allo/logic/core.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupProfilePicture extends HookWidget {
  const SetupProfilePicture({super.key});
  @override
  Widget build(BuildContext context) {
    final percentage = useState(0.0);
    void onSubmit() {
      Navigation.forward(const SetupPersonalize());
    }

    return SetupPage(
      icon: Icons.landscape,
      title: Text(context.loc.setupProfilePictureScreenTitle),
      subtitle: Text(context.loc.setupProfilePictureScreenDescription),
      body: [
        Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 110,
                    width: 110,
                    child: ProgressRing(
                      value: percentage.value,
                    ),
                  ),
                  PersonPicture(
                    radius: 100,
                    profilePicture: Core.auth.user.profilePictureUrl,
                    initials: Core.auth.user.nameInitials,
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(context.loc.uploadPicture),
              onTap: () async => await Core.auth.user.updateProfilePicture(
                percentage: percentage,
                context: context,
                route: const SetupPersonalize(),
              ),
            ),
          ],
        ),
      ],
      action: onSubmit,
    );
  }
}
