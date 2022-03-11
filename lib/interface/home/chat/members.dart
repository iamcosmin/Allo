import 'package:allo/components/person_picture.dart';
import 'package:allo/interface/home/chat/chat_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../components/builders.dart';
import '../../../logic/core.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> returnChatInfo(
    {required String id}) async {
  return await FirebaseFirestore.instance.collection('chats').doc(id).get();
}

class ChatMembersPage extends HookConsumerWidget {
  const ChatMembersPage({required this.chatId, Key? key}) : super(key: key);
  final String chatId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.locale.members),
      ),
      body: FutureView<DocumentSnapshot<Map<String, dynamic>>>(
        future: returnChatInfo(id: chatId),
        success: (context, data) {
          final List members = data.data()!['members'];
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, i) {
              final member = members[i];
              return ListTile(
                title: Text(member['uid'] != Core.auth.user.uid
                    ? member['name']
                    : context.locale.me),
                contentPadding: const EdgeInsets.only(
                    top: 5, bottom: 5, left: 10, right: 10),
                leading: PersonPicture(
                  radius: 50,
                  profilePicture: Core.auth.getProfilePicture(
                    member['uid'],
                  ),
                  initials: Core.auth.returnNameInitials(
                    member['name'],
                  ),
                ),
                onTap: () => Core.navigation.push(
                  route: const UserPreviewPage(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
