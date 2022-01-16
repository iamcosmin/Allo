import 'package:allo/components/chats/bubbles/sent.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final themes = <Map>[
  {
    'name': 'Albastru',
    'color': Colors.blue,
    'id': 'blue',
  },
  {
    'name': 'Mov',
    'color': Colors.purple,
    'id': 'purple',
  },
  {
    'name': 'Rosu',
    'color': Colors.red,
    'id': 'red',
  },
  {
    'name': 'Turcoaz',
    'color': Colors.cyan,
    'id': 'cyan',
  },
  {
    'name': 'Roz',
    'color': Colors.pink,
    'id': 'pink',
  },
  {
    'name': 'Verde smarald',
    'color': const Color(0xFF1a521f),
    'id': 'smarald_green'
  },
  {
    'name': 'Vișiniu',
    'color': const Color(0xFF571047),
    'id': 'burgundy',
  },
  {
    'name': 'Special: Gina',
    'color': const Color(0xFF4f5a8f),
    'id': 'special_gina'
  }
];

List themesId() {
  var list = [];
  for (var theme in themes) {
    list.add(theme['id']);
  }
  return list;
}

void _changeTheme({
  required BuildContext context,
  required String id,
}) async {
  final info = await returnChatInfo(id: id);
  var currentTheme = info.data()!['theme'];
  showMagicBottomSheet(
    context: context,
    title: 'Temă',
    insets: const ScrollableInsets(
        initialChildSize: 0.5, minChildSize: 0.5, maxChildSize: 0.8),
    children: [
      if (currentTheme == null) ...[
        const SwitchListTile(
          title: Text('Notificări'),
          onChanged: null,
          value: true,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
          child: Text(
              'Tema curentă a conversației nu e disponibilă în versiunea aceasta a aplicației.'),
        )
      ],
      for (var theme in themes) ...[
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          child: ListTile(
            title: Text(theme['name']),
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: theme['color'],
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            trailing: currentTheme == theme['id']
                ? const Icon(Icons.check_rounded)
                : null,
            onTap: () async {
              await FirebaseFirestore.instance
                  .collection('chats')
                  .doc(id)
                  .update({
                'theme': theme['id'],
              });
              Navigator.of(context).pop();
            },
          ),
        ),
      ]
    ],
  );
}

void _showParticipants(
    {required BuildContext context, required String id}) async {
  final info = await returnChatInfo(id: id);
  final members = info.data()!['members'];
  showMagicBottomSheet(
    context: context,
    title: 'Participanți',
    insets: const ScrollableInsets(
        initialChildSize: 0.4, minChildSize: 0.4, maxChildSize: 0.8),
    children: [
      for (var member in members) ...[
        ListTile(
          title:
              Text(member['uid'] != Core.auth.user.uid ? member['name'] : 'Eu'),
          subtitle: Text('uid: ' + member['uid']),
          contentPadding:
              const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
          leading: PersonPicture.determine(
            radius: 50,
            profilePicture: await Core.auth.getUserProfilePicture(
              member['uid'],
            ),
            initials: Core.auth.returnNameInitials(
              member['name'],
            ),
          ),
        ),
      ]
    ],
  );
}

Future<DocumentSnapshot<Map<String, dynamic>>> returnChatInfo(
    {required String id}) async {
  return await FirebaseFirestore.instance.collection('chats').doc(id).get();
}

class ChatDetails extends HookConsumerWidget {
  const ChatDetails(
      {Key? key, required this.name, required this.id, this.profilepic})
      : super(key: key);
  final String name;
  final String id;
  final String? profilepic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(participantsDebug);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalii conversație'),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            alignment: Alignment.topCenter,
            child: InkWell(
              highlightColor: const Color(0x00000000),
              focusColor: const Color(0x00000000),
              hoverColor: const Color(0x00000000),
              splashColor: const Color(0x00000000),
              onTap: profilepic == null
                  ? null
                  : () => Core.navigation
                      .push(context: context, route: ImageView(profilepic!)),
              child: PersonPicture.determine(
                profilePicture: profilepic,
                radius: 100,
                color: Colors.green,
                initials: Core.auth.returnNameInitials(name),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 15),
            alignment: Alignment.topCenter,
            child: Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
            child: Column(
              children: [
                const SwitchListTile(
                  secondary: Icon(Icons.notifications_outlined),
                  title: Text('Notificări'),
                  onChanged: null,
                  value: true,
                ),
                ListTile(
                  leading: const Icon(Icons.brush_outlined),
                  title: const Text('Temă'),
                  onTap: () async => _changeTheme(context: context, id: id),
                ),
                if (participants == true) ...[
                  ListTile(
                    leading: const Icon(Icons.people_alt_outlined),
                    title: const Text('Participanți'),
                    onTap: () async =>
                        _showParticipants(context: context, id: id),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}
