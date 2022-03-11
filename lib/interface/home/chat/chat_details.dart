import 'package:allo/components/image_view.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/components/space.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/chat/members.dart';
import 'package:allo/logic/client/hooks.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/models/chat.dart';
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

Future<DocumentSnapshot<Map<String, dynamic>>> returnChatInfo(
    {required String id}) async {
  return await FirebaseFirestore.instance.collection('chats').doc(id).get();
}

class ChatDetails extends HookConsumerWidget {
  const ChatDetails({Key? key, required this.chat}) : super(key: key);
  final Chat chat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final members = usePreference(ref, membersDebug);
    final profilePicture = Core.auth.getProfilePicture(
        chat is PrivateChat ? (chat as PrivateChat).userId : chat.id,
        isGroup: chat is GroupChat ? true : false);
    return Scaffold(
      appBar: AppBar(
        title: Text(locales.chatInfo),
      ),
      body: ListView(
        children: [
          const Space(3),
          Container(
            alignment: Alignment.topCenter,
            child: InkWell(
              highlightColor: const Color(0x00000000),
              focusColor: const Color(0x00000000),
              hoverColor: const Color(0x00000000),
              splashColor: const Color(0x00000000),
              onTap: profilePicture == null
                  ? null
                  : () =>
                      Core.navigation.push(route: ImageView(profilePicture)),
              child: PersonPicture(
                profilePicture: profilePicture,
                radius: 150,
                initials: Core.auth.returnNameInitials(chat.title),
              ),
            ),
          ),
          const Space(3),
          Container(
            alignment: Alignment.topCenter,
            child: Text(
              chat.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Space(4),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brush_outlined),
                  title: Text(locales.theme),
                  onTap: () async =>
                      _changeTheme(context: context, id: chat.id),
                ),
                if (members.preference == true) ...[
                  ListTile(
                    leading: const Icon(Icons.people_alt_outlined),
                    title: Text(locales.members),
                    onTap: () => Core.navigation
                        .push(route: ChatMembersPage(chatId: chat.id)),
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
