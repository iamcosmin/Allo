import 'package:allo/interface/home/secret_settings.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Icon;
import 'package:flutter/cupertino.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: invalid_use_of_protected_member
    final themeState = useProvider(Repositories.themeState.notifier).state;
    final theme = useProvider(Repositories.themeState.notifier);
    final auth = useProvider(Repositories.auth);
    final navigation = useProvider(Repositories.navigation);
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('Setări'),
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
                    CupertinoFormRow(
                      prefix: Text('Imagine de profil'),
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
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: Text('Personalizare'),
                  children: [
                    CupertinoFormRow(
                        prefix: Text('Activează modul întunecat'),
                        child: CupertinoSwitch(
                          value: themeState,
                          onChanged: (value) {
                            if (themeState) {
                              return theme.switchToLight(context);
                            } else {
                              return theme.switchToDark(context);
                            }
                          },
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
                    CupertinoFormRow(
                      prefix: Text('Debug'),
                      child: CupertinoButton(
                        onPressed: () =>
                            navigation.to(context, SecretSettings()),
                        child: Text('Access'),
                      ),
                    )
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
