import 'package:allo/components/person_picture.dart';
import 'package:allo/components/slivers/sliver_center.dart';
import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:allo/interface/home/chat/chat_preview.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/builders.dart';
import '../../../logic/core.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> returnChatInfo({
  required String id,
}) async {
  return await Database.firestore.collection('chats').doc(id).get();
}

class ChatMembersPage extends HookConsumerWidget {
  const ChatMembersPage({required this.chatId, super.key});
  final String chatId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SScaffold(
      topAppBar: LargeTopAppBar(title: Text(context.loc.members)),
      slivers: [
        FutureWidget<DocumentSnapshot<Map<String, dynamic>>>(
          future: returnChatInfo(id: chatId),
          loading: () {
            return const SliverCenter(
              child: ProgressRing(),
            );
          },
          error: (error) {
            return SliverCenter(
              child: Text(error.toString()),
            );
          },
          success: (data) {
            final List members = data.data()!['members'];
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final member = members[index];
                  return ListTile(
                    title: Text(
                      member['uid'] != Core.auth.user.userId
                          ? member['name']
                          : context.loc.me,
                    ),
                    contentPadding: const EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                      left: 10,
                      right: 10,
                    ),
                    leading: PersonPicture(
                      radius: 50,
                      profilePicture: Core.auth.getProfilePicture(
                        member['uid'],
                      ),
                      initials: Core.auth.returnNameInitials(
                        member['name'],
                      ),
                    ),
                    onTap: () => Navigation.forward(
                      const UserPreviewPage(),
                    ),
                  );
                },
                childCount: members.length,
              ),
            );
          },
        )
      ],
    );
  }
}
