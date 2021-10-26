import 'package:allo/components/person_picture.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:allo/interface/home/chat/chat.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final chats = useProvider(loadChats);
    final chatsMethod = useProvider(loadChats.notifier);
    useEffect(() {
      chatsMethod.getChatsData(context);
    }, const []);

    String type(type) {
      if (type == ChatType.group) {
        return 'Grup';
      } else if (type == ChatType.private) {
        return 'Privat';
      } else {
        return 'Unknown';
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade700,
        onPressed: null,
        child: const Icon(Icons.add),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, ibs) => [
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(
                'Conversații',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).appBarTheme.foregroundColor),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
              background: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            expandedHeight: 100,
            pinned: true,
          ),
        ],
        body: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: () async => await chatsMethod.getChatsData(context),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 20),
            children: [
              if (chats.isNotEmpty) ...[
                for (var chat in chats) ...[
                  ListTile(
                    title: Text(chat['name']),
                    subtitle: Text(type(chat['type']) + ' (${chat['chatId']})'),
                    leading: PersonPicture.determine(
                      profilePicture: chat['profilepic'],
                      radius: 50,
                      color: Theme.of(context).colorScheme.secondary,
                      initials: Core.auth.returnNameInitials(
                        chat['name'],
                      ),
                    ),
                    onTap: () => Core.navigation.push(
                      context: context,
                      route: Chat(
                        chatType: chat['type'],
                        title: chat['name'],
                        chatId: chat['chatId'],
                        profilepic: chat['profilepic'],
                      ),
                    ),
                  ),
                ],
              ] else ...[
                const ListTile(title: Text('Nicio conversație.'))
              ],
            ],
          ),
        ),
      ),
    );
  }
}
