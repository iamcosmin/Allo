import 'package:allo/components/person_picture.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/logic/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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

class ChatDetails extends HookWidget {
  const ChatDetails(
      {Key? key, required this.name, required this.id, this.profilepic})
      : super(key: key);
  final String name;
  final String id;
  final String? profilepic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            alignment: Alignment.topCenter,
            child: PersonPicture.determine(
              profilePicture: profilepic,
              radius: 100,
              color: Colors.green,
              initials: Core.auth.returnNameInitials(name),
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
                ListTile(
                    title: const Text('Temă'),
                    onTap: () async {
                      var chat = await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(id)
                          .get();
                      var currentTheme = chat.data()!['theme'] ?? 'blue';
                      showMagicBottomSheet(
                        context: context,
                        title: 'Temă',
                        initialChildSize: 0.4,
                        maxChildSize: 0.75,
                        children: [
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
                                    ? const Icon(
                                        FluentIcons.checkmark_12_filled)
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
                    }),
                const ListTile(title: Text('Activează notificări')),
                const ListTile(title: Text('Dezactivează notificări'))
              ],
            ),
          )
        ],
      ),
    );
  }
}
