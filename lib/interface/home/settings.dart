import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: invalid_use_of_protected_member
    final themeState = useProvider(Repositories.themeState.notifier).state;
    final theme = useProvider(Repositories.themeState.notifier);
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('Setări'),
          ),
          SliverSafeArea(
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
                )
              ]),
            ),
          )
        ],
      ),
    );
  }
}
