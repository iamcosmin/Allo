import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/account/name.dart';
import 'package:allo/interface/home/settings/profile_picture.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AccountSettings extends HookWidget {
  const AccountSettings({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final locales = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.account),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              locales.name,
              style: const TextStyle(fontSize: 18),
            ),
            minLeadingWidth: 20,
            onTap: () {
              Core.navigation.push(
                route: const ChangeNamePage(),
              );
            },
          ),
          ListTile(
            title: Text(
              locales.username,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          ListTile(
            title: Text(
              locales.profilePicture,
              style: const TextStyle(fontSize: 18),
            ),
            onTap: () => Core.navigation.push(route: ProfilePictureSettings()),
          )
        ],
      ),
    );
  }
}
