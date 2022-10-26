import 'package:allo/components/image_view.dart';
import 'package:allo/components/material3/tile.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/components/space.dart';
import 'package:allo/components/tile_card.dart';
import 'package:allo/interface/home/chat/chat.dart';
import 'package:allo/interface/home/chat/members.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    title: context.loc.theme,
    children: [
      if (!colors.contains(currentTheme)) ...[
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
          child: Text(context.loc.themeNotAvailable),
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
                  () => context.pop();
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
    final notificationState = ref.watch(currentNotificationState(chat.id));
    final members = useSetting(ref, membersDebug);
    final profilePicture = Core.auth.getProfilePicture(
      chat is PrivateChat ? (chat as PrivateChat).userId : chat.id,
      isGroup: chat is GroupChat ? true : false,
    );
    return SScaffold(
      topAppBar: MediumTopAppBar(
        title: Text(context.loc.chatInfo),
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
                    : () => Navigation.forward(ImageView(profilePicture)),
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
            TileCard(
              [
                Tile(
                  leading: const Icon(Icons.brush_outlined),
                  title: Text(context.loc.theme),
                  onTap: () async =>
                      _changeTheme(context: context, id: chat.id),
                ),
                SwitchTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(context.loc.notifications),
                  value: notificationState ?? false,
                  enabledIcon: Icons.notifications_active,
                  disabledIcon: Icons.notifications_off,
                  disabled: notificationState == null,
                  subtitle: notificationState != null
                      ? null
                      : const Text(
                          'Notifications are not supported on this platform.',
                        ),
                  onChanged: ref
                      .read(currentNotificationState(chat.id).notifier)
                      .toggleNotificationState,
                ),
                if (members.setting == true) ...[
                  Tile(
                    leading: const Icon(Icons.people_alt_outlined),
                    title: Text(context.loc.members),
                    onTap: () => Navigation.forward(
                      ChatMembersPage(chatId: chat.id),
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
