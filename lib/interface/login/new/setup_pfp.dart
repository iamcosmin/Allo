import 'package:allo/components/oobe_page.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/new/setup_personalize.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SetupProfilePicture extends HookWidget {
  const SetupProfilePicture({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    final percentage = useState(0.0);
    final loaded = useState(false);
    return SetupPage(
      icon: Icons.landscape,
      title: context.locale.setupProfilePictureScreenTitle,
      subtitle: context.locale.setupProfilePictureScreenDescription,
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
                      initials: Core.auth.user.nameInitials),
                ],
              ),
            ),
            ListTile(
              title: Text(locales.uploadPicture),
              onTap: () async => await Core.auth.user.updateProfilePicture(
                  loaded: loaded,
                  percentage: percentage,
                  context: context,
                  route: const SetupPersonalize()),
            ),
          ],
        ),
      ],
      action: () async => true,
      nextRoute: const SetupPersonalize(),
    );
  }
}
