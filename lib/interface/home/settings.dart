import 'package:allo/interface/home/concentrated.dart';
import 'package:allo/interface/home/settings/profile_picture.dart';
import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final dark = useProvider(darkMode);
    final auth = useProvider(Repositories.auth);
    final navigation = useProvider(Repositories.navigation);
    final darkMethod = useProvider(darkMode.notifier);
    final name = FirebaseAuth.instance.currentUser!.displayName!;
    // DO NOT REMOVE
    final _a = useState(0);
    void _b() {
      _a.value++;
      if (_a.value == 9) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => C()));
        _a.value = 0;
      }
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, i) => [
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: GestureDetector(onTap: () => _b(), child: Text('Setări')),
            ),
            expandedHeight: 100,
            pinned: true,
          ),
        ],
        body: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              children: [
                CupertinoFormRow(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: PersonPicture.determine(
                            radius: 100,
                            profilePicture: auth.returnProfilePicture(),
                            initials: auth.returnAuthenticatedNameInitials()),
                      ),
                      Text(name),
                      Padding(padding: EdgeInsets.only(bottom: 10))
                    ],
                  ),
                )
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: Text('Cont'),
              children: [
                //     CupertinoFormRow(
                //       prefix: Text('Nume'),
                //       child: Padding(
                //         padding: const EdgeInsets.only(
                //             top: 10, bottom: 10, right: 5),
                //         child: Icon(
                //           CupertinoIcons.right_chevron,
                //           color: CupertinoColors.systemGrey,
                //           size: 15,
                //         ),
                //       ),
                //     ),             TODO: NON FUNCTIONAL
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePictureSettings())),
                  child: CupertinoFormRow(
                    prefix: Text('Fotografie de profil'),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, right: 5),
                      child: Icon(
                        CupertinoIcons.right_chevron,
                        color: CupertinoColors.systemGrey,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: Text('Personalizare'),
              children: [
                CupertinoFormRow(
                  prefix: Text('Mod întunecat'),
                  child: CupertinoSwitch(
                      value: dark,
                      onChanged: (value) => darkMethod.switcher(context)),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
                header: Text('Gestionare sesiune'),
                children: [
                  GestureDetector(
                    onTap: () async => await auth.signOut(context),
                    child: CupertinoFormRow(
                      prefix: Text('Deconectare'),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, right: 5),
                        child: Icon(
                          CupertinoIcons.right_chevron,
                          color: CupertinoColors.systemGrey,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ])
          ],
        ),
      ),
    );
  }
}
