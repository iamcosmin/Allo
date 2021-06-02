import 'package:allo/interface/home/secret_settings.dart';
import 'package:allo/interface/home/settings/profile_picture.dart';
import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Icon;
import 'package:flutter/cupertino.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final dark = useProvider(darkMode);
    final auth = useProvider(Repositories.auth);
    final navigation = useProvider(Repositories.navigation);
    final entry = useProvider(secretEntryProvider);
    final entryMethod = useProvider(secretEntryProvider.notifier);
    //
    final eProfilePic = useProvider(experimentalProfilePicture);
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: GestureDetector(
              onTap: () {
                entryMethod.increment();
                if (entry == 9) {
                  navigation.to(context, SecretSettings());
                  entryMethod.reset();
                }
              },
              child: Text('Setări'),
            ),
          ),
          SliverSafeArea(
            minimum: EdgeInsets.only(top: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                CupertinoFormSection.insetGrouped(
                  children: [
                    CupertinoFormRow(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: PersonPicture.initials(
                                  radius: 100,
                                  initials: 'CR',
                                  color:
                                      CupertinoTheme.of(context).primaryColor)),
                          Text('Cosmin'),
                          Padding(padding: EdgeInsets.only(bottom: 10))
                        ],
                      ),
                    )
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: Text('Cont'),
                  children: [
                    CupertinoFormRow(
                      prefix: Text('Nume'),
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
                    if (eProfilePic) ...[
                      GestureDetector(
                        onTap: () =>
                            navigation.to(context, ProfilePictureSettings()),
                        child: CupertinoFormRow(
                          prefix: Text('Fotografie de profil'),
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
                    ],
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: Text('Personalizare'),
                  children: [
                    CupertinoFormRow(
                        prefix: Text('Mod Întunecat'),
                        child: CupertinoSwitch(
                          value: dark,
                          onChanged: null,
                        ))
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: Text('Gestionare sesiune'),
                  children: [
                    GestureDetector(
                      onTap: () async => await auth.signOut(),
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
                  ],
                )
              ]),
            ),
          )
        ],
      ),
    );
  }
}
