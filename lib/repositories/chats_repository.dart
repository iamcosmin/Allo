import 'package:allo/logic/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatType {
  static const String private = 'private';
  static const String group = 'group';
}

final loadChats = StateNotifierProvider<LoadChats, List>((ref) => LoadChats());

class LoadChats extends StateNotifier<List> {
  LoadChats() : super(['Loading']);

  Future newGetChatsData(BuildContext context) async {
    final username = Core.auth.user.uid;
    QuerySnapshot documents = await FirebaseFirestore.instance
        .collection("chats")
        .where("participants", arrayContains: username)
        .get();
    var listOfMapChatInfo = <Map>[];
    if (documents.docs.isNotEmpty) {
      for (var chat in documents.docs) {
        var chatInfoMap = chat.data() as Map;
        // ignore: prefer_typing_uninitialized_variables
        var name, profilepic, chatid;
        // Check if it is group or private
        if (chatInfoMap['type'] == ChatType.private) {
          chatid = chat.id;
          for (Map member in chatInfoMap['members']) {
            if (member['uid'] != Core.auth.user.uid) {
              name = member['name'];
              profilepic = member['profilepicture'];
            }
          }
          listOfMapChatInfo.add({
            'type': ChatType.private,
            'name': name,
            'profilepic': profilepic,
            'chatId': chatid
          });
        } else if (chatInfoMap['type'] == ChatType.group) {
          if (chatInfoMap.containsKey('title')) {
            var chatInfo = {
              'type': ChatType.group,
              'name': chatInfoMap['title'],
              'chatId': chat.id,
              'profilepic': chatInfoMap['profilepic']
            };
            listOfMapChatInfo.add(chatInfo);
          }
        }
      }
      state = listOfMapChatInfo;
    } else {
      state = ['Loading'];
    }
  }

  Future getChatsData(BuildContext context) async {
    var chatIdList = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(await Core.auth.user.username)
        .get()
        .then((DocumentSnapshot snapshot) {
      var map = snapshot.data() as Map;
      if (map.containsKey('chats')) {
        chatIdList = map['chats'] as List;
      }
    });

    var listOfMapChatInfo = <Map>[];
    if (chatIdList.isNotEmpty) {
      for (var chat in chatIdList) {
        var chatSnapshot = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chat)
            .get();
        var chatInfoMap = chatSnapshot.data() as Map;
        // ignore: prefer_typing_uninitialized_variables
        var name, profilepic, chatid;
        // Check if it is group or private
        if (chatInfoMap['type'] == ChatType.private) {
          chatid = chatSnapshot.id;
          for (Map member in chatInfoMap['members']) {
            if (member['uid'] != Core.auth.user.uid) {
              name = member['name'];
              profilepic = member['profilepicture'];
            }
          }
          listOfMapChatInfo.add({
            'type': ChatType.private,
            'name': name,
            'profilepic': profilepic,
            'chatId': chatid
          });
        } else if (chatInfoMap['type'] == ChatType.group) {
          if (chatInfoMap.containsKey('title')) {
            var chatInfo = {
              'type': ChatType.group,
              'name': chatInfoMap['title'],
              'chatId': chatSnapshot.id,
              'profilepic': chatInfoMap['profilepic']
            };
            listOfMapChatInfo.add(chatInfo);
          }
        }
      }
    }
    state = listOfMapChatInfo;
  }
}
