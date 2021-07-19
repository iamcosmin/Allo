import 'package:allo/components/list/list_section.dart';
import 'package:allo/components/list/list_tile.dart';
import 'package:allo/components/person_picture.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:allo/components/refresh.dart';
import 'package:allo/interface/home/chat/chat.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final navigation = useProvider(Repositories.navigation);
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return CupertinoPageScaffold(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(100.0),
              child: Text(
                'Ne bucuram ca vrei sa incerci versiunea de desktop, insa aceasta nu este gata. Revino mai tarziu!',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      } else {
        return CupertinoPageScaffold(
            child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text(
                'Conversații',
              ),
            ),
            FluentSliverRefreshControl(
              onRefresh: () => Future.delayed(Duration(seconds: 3), null),
              // ignore: unnecessary_null_comparison
            ),
            SliverSafeArea(
                sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(padding: EdgeInsets.only(top: 20)),
                CupertinoListSection.insetGrouped(
                  header: Text('Featured'),
                  children: [
                    CupertinoListTile(
                      title: Text('Allo'),
                      subtitle: Column(children: [
                        ProgressBar(),
                        Padding(padding: EdgeInsets.only(bottom: 10))
                      ]),
                      leading: PersonPicture.initials(
                        radius: 30,
                        initials: 'A',
                        color: CupertinoColors.systemPurple,
                      ),
                      onTap: () => navigation.to(context, Chat(title: 'Allo')),
                    ),
                  ],
                ),
              ]),
            ))
          ],
        ));
      }
    });
  }
}
