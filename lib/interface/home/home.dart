import 'package:allo/components/person_picture.dart';
import 'package:allo/interface/home/create_chat.dart';
import 'package:allo/repositories/chats_repository.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:allo/interface/home/chat/chat.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final navigation = useProvider(Repositories.navigation);
    final auth = useProvider(Repositories.auth);
    final chats = useProvider(loadChats);
    final chatsMethod = useProvider(loadChats.notifier);
    useEffect(() {
      Future.microtask(() async {
        await chatsMethod.getChatsData(context);
      });
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => CreateChat())),
        child: const Icon(Icons.add),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, ibs) => [
          const SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text('Conversații'),
              titlePadding: EdgeInsets.only(left: 20, bottom: 15),
            ),
            expandedHeight: 100,
            pinned: true,
          ),
        ],
        body: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: () async => await chatsMethod.getChatsData(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Allo'),
                  leading: Hero(
                    tag: 'DFqPHH2R4E5j0tM55fIm_pic',
                    child: Material(
                      color: Colors.transparent,
                      child: PersonPicture.initials(
                        radius: 50,
                        color: Colors.blue,
                        initials: auth.returnNameInitials(
                          'Allo',
                        ),
                      ),
                    ),
                  ),
                  onTap: () => navigation.push(
                      context,
                      Chat(
                        chatType: ChatType.group,
                        title: 'Allo',
                        chatId: 'DFqPHH2R4E5j0tM55fIm',
                      )),
                ),
                if (chats.isNotEmpty) ...[
                  for (var chat in chats) ...[
                    if (chat['type'] == ChatType.private) ...[
                      ListTile(
                        title: Text(chat['name']),
                        leading: Hero(
                          tag: chat['chatId'] + '_pic',
                          child: Material(
                            color: Colors.transparent,
                            child: PersonPicture.determine(
                              profilePicture: chat['profilepic'],
                              radius: 50,
                              color: Colors.blue,
                              initials: auth.returnNameInitials(
                                chat['name'],
                              ),
                            ),
                          ),
                        ),
                        onTap: () => navigation.push(
                            context,
                            Chat(
                              chatType: chat['type'],
                              title: chat['name'],
                              chatId: chat['chatId'],
                            )),
                      ),
                    ] else if (chat['type'] == ChatType.group) ...[
                      ListTile(
                        title: Text(chat['name']),
                        subtitle: Text(chat['chatId']),
                        leading: Hero(
                          tag: chat['chatId'],
                          child: Material(
                            child: PersonPicture.initials(
                              radius: 50,
                              color: Colors.blue,
                              initials: auth.returnNameInitials(
                                chat['name'],
                              ),
                            ),
                          ),
                        ),
                        onTap: () => navigation.push(
                            context,
                            Chat(
                              chatType: chat['type'],
                              title: chat['name'],
                              chatId: chat['chatId'],
                            )),
                      ),
                    ],
                  ]
                ] else ...[
                  const ListTile(title: Text('Nicio conversație.'))
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
