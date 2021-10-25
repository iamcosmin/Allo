import 'package:allo/components/person_picture.dart';
import 'package:allo/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final themes = <Map>[
  {'name': 'Albastru', 'color': Colors.blue, 'id': 'blue'},
  {'name': 'Mov', 'color': Colors.purple, 'id': 'purple'},
  {'name': 'Rosu', 'color': Colors.red, 'id': 'red'},
  {'name': 'Turcoaz', 'color': Colors.cyan, 'id': 'cyan'},
  {'name': 'Roz', 'color': Colors.pink, 'id': 'pink'},
];

final themesId = ['blue', 'purple', 'red', 'cyan', 'pink'];

class ChatDetails extends HookWidget {
  const ChatDetails({
    Key? key,
    required this.name,
    required this.id,
  }) : super(key: key);
  final String name;
  final String id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            alignment: Alignment.topCenter,
            child: PersonPicture.initials(
              radius: 100,
              color: Colors.green,
              initials: AuthRepository().returnNameInitials(name),
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
                      showBottomSheet(
                        context: context,
                        title: 'Temă',
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

  Future<dynamic> showBottomSheet(
      {required BuildContext context,
      required String title,
      required List<Widget> children}) {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.4,
          maxChildSize: 0.75,
          expand: false,
          builder: (context, controller) {
            return Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 10)),
                Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey
                        : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 20),
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ListView(
                      controller: controller,
                      children: children,
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
