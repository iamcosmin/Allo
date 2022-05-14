import 'package:allo/components/person_picture.dart';
import 'package:allo/components/setup_page.dart';
import 'package:allo/interface/login/new/setup_personalize.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupProfilePicture extends HookWidget {
  const SetupProfilePicture({super.key});
  @override
  Widget build(BuildContext context) {
    final percentage = useState(0.0);
    final loaded = useState(false);
    void onSubmit() {
      Core.navigation.push(route: const SetupPersonalize());
    }

    return SetupPage(
      icon: Icons.landscape,
      title: Text(context.locale.setupProfilePictureScreenTitle),
      subtitle: Text(context.locale.setupProfilePictureScreenDescription),
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
                    child: CircularProgressIndicator(
                      value: percentage.value,
                    ),
                  ),
                  PersonPicture(
                    radius: 100,
                    profilePicture: Core.auth.user.profilePicture,
                    initials: Core.auth.user.nameInitials,
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(context.locale.uploadPicture),
              onTap: () async => await Core.auth.user.updateProfilePicture(
                loaded: loaded,
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
