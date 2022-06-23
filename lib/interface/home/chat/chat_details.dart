import 'package:allo/components/image_view.dart';
import 'package:allo/components/material3/tile.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/components/space.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/home/chat/members.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/slivers/sliver_scaffold.dart';
import '../../../components/slivers/top_app_bar.dart';

final colors = <int>[
  for (var color in Colors.accents) ...[color.value]
];

void _changeTheme({
  required BuildContext context,
  required String id,
}) async {
  final info = await returnChatInfo(id: id);
  final currentTheme = info.data()!['theme'];
  await showMagicBottomSheet(
    context: context,
    title: context.locale.theme,
    children: [
      if (!colors.contains(currentTheme)) ...[
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
          child: Text(context.locale.themeNotAvailable),
        )
      ],
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var color in colors) ...[
            ClipOval(
              child: InkWell(
                onTap: () async {
                  await Database.firestore.collection('chats').doc(id).update({
                    'theme': color,
                  });
                  Navigation.pop();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      color: Color(color),
                    ),
                    if (currentTheme == color) ...[
                      Container(
                        height: 60,
                        width: 60,
                        color: Colors.black.withOpacity(0.5),
                        child: const Icon(
                          Icons.check,
                          size: 40,
                        ),
                      )
                    ],
                  ],
                ),
              ),
            )
          ],
        ],
      ),
      const Space(2)
    ],
  );
}

Future<DocumentSnapshot<Map<String, dynamic>>> returnChatInfo({
  required String id,
}) async {
  return await Database.firestore.collection('chats').doc(id).get();
}

class ChatDetails extends HookConsumerWidget {
  const ChatDetails({
    required this.chat,
    super.key,
  });
  final Chat chat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final members = useSetting(ref, membersDebug);
    final profilePicture = Core.auth.getProfilePicture(
      chat is PrivateChat ? (chat as PrivateChat).userId : chat.id,
      isGroup: chat is GroupChat ? true : false,
    );
    return SScaffold(
      topAppBar: LargeTopAppBar(
        title: Text(locales.chatInfo),
      ),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed([
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
                    : () => Navigation.push(route: ImageView(profilePicture)),
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
                style: context.theme.textTheme.headlineLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Space(4),
            Column(
              children: [
                Tile(
                  leading: const Icon(Icons.brush_outlined),
                  title: Text(locales.theme),
                  onTap: () async =>
                      _changeTheme(context: context, id: chat.id),
                ),
                if (members.setting == true) ...[
                  Tile(
                    leading: const Icon(Icons.people_alt_outlined),
                    title: Text(locales.members),
                    onTap: () => Navigation.push(
                      route: ChatMembersPage(chatId: chat.id),
                    ),
                  ),
                ]
              ],
            )
          ]),
        )
      ],
    );
  }
}
