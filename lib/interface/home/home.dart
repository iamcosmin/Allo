import 'package:allo/components/person_picture.dart';
import 'package:allo/interface/home/settings/debug/create_chat.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:allo/logic/types.dart';
import 'package:flutter/material.dart';
import 'package:allo/interface/home/chat/chat.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

String type(type) {
  if (type == ChatType.group) {
    return 'Grup';
  } else if (type == ChatType.private) {
    return 'Privat';
  } else {
    return 'Unknown';
  }
}

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadChats = useState(Core.chat('').getChatsList(context));
    final createChat = ref.watch(privateConversations);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: createChat == false ? Colors.grey.shade700 : null,
        onPressed: createChat == false
            ? null
            : () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CreateChat())),
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
                    color: Theme.of(context).appBarTheme.foregroundColor,
                    fontSize: 24),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
              background: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            expandedHeight: 170,
            pinned: true,
          ),
        ],
        body: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: () =>
              loadChats.value = Core.chat('').getChatsList(context),
          child: FutureBuilder<List<Map<String, String?>>>(
            future: loadChats.value,
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, String?>>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  padding: const EdgeInsets.all(5),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final chat = snapshot.data![index];
                    return ListTile(
                      title: Text(chat['name'] ?? 'Niciun nume'),
                      subtitle: Text(
                        type(
                              chat['type'],
                            ) +
                            ' (${chat['chatId']})',
                      ),
                      leading: PersonPicture.determine(
                        profilePicture: chat['profilepic'] ?? '',
                        radius: 50,
                        color: Theme.of(context).colorScheme.secondary,
                        initials: Core.auth.returnNameInitials(
                          chat['name'] ?? 'N',
                        ),
                      ),
                      onTap: () => Core.navigation.push(
                        context: context,
                        route: Chat(
                          chatType: chat['type']!,
                          title: chat['name'] ?? 'Niciun nume',
                          chatId: chat['chatId']!,
                          profilepic: chat['profilepic'],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
