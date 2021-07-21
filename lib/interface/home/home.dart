import 'package:allo/components/list/list_section.dart';
import 'package:allo/components/list/list_tile.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/progress_rings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final chats = useState<List>([]);

    void _getChatsData() {
      var _chatIdList = [];
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((DocumentSnapshot snapshot) {
        var _map = snapshot.data() as Map;
        if (_map.containsKey('chats')) {
          _chatIdList = _map['chats'] as List<String>;
        }
      });

      if (_chatIdList.isNotEmpty) {
        for (var _chat in _chatIdList) {
          FirebaseFirestore.instance
              .collection('chats')
              .doc(_chat)
              .get()
              .then((DocumentSnapshot snapshot) {
            var _chatInfoMap = snapshot.data() as Map;
            var _chatInfo;
            if (_chatInfoMap.containsKey('name')) {
              _chatInfo = {
                'name': _chatInfoMap['name'],
                'chatId': snapshot.id,
              };
            }
            chats.value.add(_chatInfo);
          });
        }
      }
    }

    useEffect(() {
      _getChatsData();
    }, const []);

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
              onRefresh: () => Future.delayed(Duration(seconds: 2), null),
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
                CupertinoListSection.insetGrouped(
                    header: Text('Conversații'), children: [])
              ]),
            ))
          ],
        ));
      }
    });
  }
}
