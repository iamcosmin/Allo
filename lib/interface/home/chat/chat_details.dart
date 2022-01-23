import 'package:allo/components/image_view.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

List<Map> themes(BuildContext context) {
  final locales = S.of(context);
  return [
    {
      'name': locales.themeBlue,
      'color': Colors.blue,
      'id': 'blue',
    },
    {
      'name': locales.themePurple,
      'color': Colors.purple,
      'id': 'purple',
    },
    {
      'name': locales.themeRed,
      'color': Colors.red,
      'id': 'red',
    },
    {
      'name': locales.themeCyan,
      'color': Colors.cyan,
      'id': 'cyan',
    },
    {
      'name': locales.themePink,
      'color': Colors.pink,
      'id': 'pink',
    },
    {
      'name': locales.themeEmerald,
      'color': const Color(0xFF1a521f),
      'id': 'smarald_green'
    },
    {
      'name': locales.themeBurgundy,
      'color': const Color(0xFF571047),
      'id': 'burgundy',
    },
    {
      'name': 'Special: Gina',
      'color': const Color(0xFF4f5a8f),
      'id': 'special_gina'
    }
  ];
}

List themesId(BuildContext context) {
  var list = [];
  for (var theme in themes(context)) {
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
  final locales = S.of(context);
  showMagicBottomSheet(
    context: context,
    title: locales.theme,
    insets: const ScrollableInsets(
        initialChildSize: 0.5, minChildSize: 0.5, maxChildSize: 0.8),
    children: [
      if (!themesId(context).contains(currentTheme)) ...[
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
          child: Text(locales.themeNotAvailable),
        )
      ],
      for (var theme in themes(context)) ...[
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

void _showMembers({required BuildContext context, required String id}) async {
  final info = await returnChatInfo(id: id);
  final members = info.data()!['members'];
  final locales = S.of(context);
  showMagicBottomSheet(
    context: context,
    title: locales.members,
    insets: const ScrollableInsets(
        initialChildSize: 0.4, minChildSize: 0.4, maxChildSize: 0.8),
    children: [
      for (var member in members) ...[
        ListTile(
          title: Text(member['uid'] != Core.auth.user.uid
              ? member['name']
              : locales.me),
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
    final locales = S.of(context);
    final members = ref.watch(membersDebug);
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.chatInfo),
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
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: Text(locales.notifications),
                  onChanged: null,
                  value: true,
                ),
                ListTile(
                  leading: const Icon(Icons.brush_outlined),
                  title: Text(locales.theme),
                  onTap: () async => _changeTheme(context: context, id: id),
                ),
                if (members == true) ...[
                  ListTile(
                    leading: const Icon(Icons.people_alt_outlined),
                    title: Text(locales.members),
                    onTap: () async => _showMembers(context: context, id: id),
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
