import 'package:allo/components/person_picture.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/settings/debug/create_chat.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:allo/logic/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:allo/interface/home/chat/chat.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

String type(type, BuildContext context) {
  final locales = S.of(context);
  if (type == ChatType.group) {
    return locales.group;
  } else if (type == ChatType.private) {
    return locales.private;
  } else {
    return locales.unknown;
  }
}

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadChats = useState(Core.chat('').getChatsList(context));
    final createChat = ref.watch(privateConversations);
    final locales = S.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onPressed: createChat == false
            ? () => Core.stub.showInfoBar(
                context: context,
                icon: Icons.info_outline_rounded,
                text: 'Această funcție va fi disponibilă în curând.')
            : () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CreateChat())),
        label: Text(
          locales.createNewChat,
          style: const TextStyle(fontFamily: 'GS-Text', letterSpacing: 0),
        ),
        icon: const Icon(Icons.create_outlined),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, ibs) => [
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(
                locales.chats,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
              background: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            expandedHeight: 152,
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
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Builder(builder: (context) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(5),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final chat = snapshot.data![index];
                        return ListTile(
                          title: Text(chat['name'] ?? '???'),
                          subtitle: Text(
                            type(chat['type'], context) +
                                ' (${chat['chatId']})',
                          ),
                          leading: PersonPicture.determine(
                            profilePicture: chat['profilepic'] ?? '',
                            radius: 50,
                            initials: Core.auth.returnNameInitials(
                              chat['name'] ?? '?',
                            ),
                          ),
                          onTap: () => Core.navigation.push(
                            context: context,
                            route: Chat(
                              chatType: chat['type']!,
                              title: chat['name'] ?? '???',
                              chatId: chat['chatId']!,
                              profilepic: chat['profilepic'],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    final errorMessage = locales.anErrorOccurred +
                        '\n' +
                        ((snapshot.error is FirebaseException)
                            ? 'Code: ${(snapshot.error as FirebaseException).code}'
                                '\n'
                                'Element: ${(snapshot.error as FirebaseException).plugin}'
                                '\n\n'
                                '${(snapshot.error as FirebaseException).message}'
                            : snapshot.error.toString());
                    return Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Center(
                        child: SelectableText(
                          errorMessage,
                        ),
                      ),
                    );
                  } else if (snapshot.data == null) {
                    return Center(
                      child: Text(locales.noChats),
                    );
                  } else {
                    return Container();
                  }
                }),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
