import 'package:allo/components/list/list_section.dart';
import 'package:allo/components/list/list_tile.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/progress_rings.dart';
import 'package:animations/animations.dart';
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
    final auth = useProvider(Repositories.auth);
    final chats = useState([]);

    Future getChatsData() async {
      var chatIdList = [];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((DocumentSnapshot snapshot) {
        var map = snapshot.data() as Map;
        if (map.containsKey('chats')) {
          chatIdList = map['chats'] as List;
        }
      });

      var listOfMapChatInfo = <Map>[];
      if (chatIdList.isNotEmpty) {
        for (var chat in chatIdList) {
          var chatSnapshot = await FirebaseFirestore.instance
              .collection('chats')
              .doc(chat)
              .get();
          var chatInfoMap = chatSnapshot.data() as Map;
          if (chatInfoMap.containsKey('title')) {
            var chatInfo = {
              'name': chatInfoMap['title'],
              'chatId': chatSnapshot.id,
            };
            listOfMapChatInfo.add(chatInfo);
          }
        }
      }
      chats.value = listOfMapChatInfo;
    }

    useEffect(() {
      Future.microtask(() async => await getChatsData());
    }, const []);

    return CupertinoPageScaffold(
        child: CustomScrollView(
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: Text(
            'Conversații',
          ),
        ),
        FluentSliverRefreshControl(
          onRefresh: () async => await getChatsData(),
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
                  onTap: () => navigation.push(
                      context,
                      Chat(
                        title: 'Allo',
                        chatId: 'DFqPHH2R4E5j0tM55fIm',
                      ),
                      SharedAxisTransitionType.scaled),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
                header: Text('Conversații'),
                children: [
                  if (chats.value.isNotEmpty) ...[
                    for (var chat in chats.value) ...[
                      CupertinoListTile(
                        title: Text(chat['name']),
                        subtitle: Text(chat['chatId']),
                        leading: PersonPicture.initials(
                          radius: 30,
                          color: CupertinoColors.activeOrange,
                          initials: auth.returnNameInitials(
                            chat['name'],
                          ),
                        ),
                        onTap: () => navigation.push(
                            context,
                            Chat(
                              title: chat['name'],
                              chatId: chat['chatId'],
                            ),
                            SharedAxisTransitionType.scaled),
                      )
                    ]
                  ] else ...[
                    CupertinoListTile(title: Text('Nicio conversație.'))
                  ]
                ])
          ]),
        ))
      ],
    ));
  }
}
