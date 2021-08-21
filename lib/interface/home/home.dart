import 'package:allo/components/person_picture.dart';
import 'package:animations/animations.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:allo/interface/home/chat/chat.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final navigation = useProvider(Repositories.navigation);
    final auth = useProvider(Repositories.auth);
    final chat = useProvider(Repositories.chats);
    final chats = useState([]);
    final colors = useProvider(Repositories.colors);

    Future getChatsData() async {
      var chatIdList = [];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(await auth.getUsername())
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
      Future.microtask(() async {
        await getChatsData();
        AwesomeNotifications()
            .actionStream
            .listen((ReceivedAction event) async {
          if (!StringUtils.isNullOrEmpty(event.buttonKeyInput)) {
            await chat.sendMessage(
                event.buttonKeyInput,
                null,
                MessageType.TEXT_ONLY,
                event.payload!['chat']!,
                event.payload!['title']!,
                null);
          }
          await navigation.push(
              context,
              Chat(
                title: event.payload!['title']!,
                chatId: event.payload!['chat']!,
              ),
              SharedAxisTransitionType.scaled);
        });
      });
    });

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, ibs) => [
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text('Conversații'),
            ),
            expandedHeight: 100,
            pinned: true,
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () async => await getChatsData(),
          child: ListView(
            children: [
              OpenContainer(
                closedColor: colors.nonColors,
                openColor: colors.nonColors,
                middleColor: Colors.transparent,
                openBuilder: (context, action) {
                  return Chat(
                    title: 'Allo',
                    chatId: 'DFqPHH2R4E5j0tM55fIm',
                  );
                },
                closedBuilder: (context, func) {
                  return ListTile(
                    title: Text('Allo'),
                    leading: Hero(
                      tag: 'pfp_image',
                      child: PersonPicture.initials(
                        radius: 50,
                        color: CupertinoColors.activeOrange,
                        initials: auth.returnNameInitials(
                          'Allo',
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (chats.value.isNotEmpty) ...[
                for (var chat in chats.value) ...[
                  OpenContainer(
                    closedColor: colors.nonColors,
                    openColor: colors.nonColors,
                    middleColor: Colors.transparent,
                    openBuilder: (context, action) {
                      return Chat(
                        title: chat['name'],
                        chatId: chat['chatId'],
                      );
                    },
                    closedBuilder: (context, func) {
                      return ListTile(
                        title: Text(chat['name']),
                        subtitle: Text(chat['chatId']),
                        leading: Hero(
                          tag: 'pfp_image',
                          child: PersonPicture.initials(
                            radius: 50,
                            color: CupertinoColors.activeOrange,
                            initials: auth.returnNameInitials(
                              chat['name'],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ]
              ] else ...[
                ListTile(title: Text('Nicio conversație.'))
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class StringUtils {
  static final RegExp _emptyRegex = RegExp(r'^\s*$');
  static bool isNullOrEmpty(String? value,
      {bool considerWhiteSpaceAsEmpty = true}) {
    if (considerWhiteSpaceAsEmpty) {
      return value == null || _emptyRegex.hasMatch(value);
    }
    return value?.isEmpty ?? true;
  }
}
