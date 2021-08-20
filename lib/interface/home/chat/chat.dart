import 'package:allo/components/firestore_animated_list/animated_firestore_list.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/message_bubble.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: must_be_immutable
class Chat extends HookWidget {
  String title;
  String chatId;
  Chat({required this.title, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final documentLoad = useState(20);
    final auth = useProvider(Repositories.auth);
    useEffect(() {
      if (!kIsWeb) {
        FirebaseMessaging.instance.subscribeToTopic(chatId);
      }
    }, const []);
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          actions: [
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: PersonPicture.initials(
                radius: 45,
                initials: auth.returnNameInitials(title),
                color: Colors.blue,
              ),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: FirestoreAnimatedList(
                  query: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('time', descending: true)
                      .limit(documentLoad.value),
                  reverse: true,
                  linear: false,
                  duration: Duration(milliseconds: 200),
                  itemBuilder: (context, snap, animation, i) {
                    final nowData, pastData, nextData;
                    nowData = snap![i]!.data() as Map;
                    if (i == 0) {
                      nextData = {'senderUID': 'null'};
                    } else {
                      nextData = snap[i - 1]!.data() as Map;
                    }
                    if (i == snap.length - 1) {
                      pastData = {'senderUID': 'null'};
                    } else {
                      pastData = snap[i + 1]!.data() as Map;
                    }
                    // Above, pastData should have been i-1 and nextData i+1.
                    // But, as the list needs to be in reverse order, we need
                    // to consider this workaround.
                    final pastUID = pastData.containsKey('senderUID')
                        ? pastData['senderUID']
                        : 'null';
                    final nextUID = nextData.containsKey('senderUID')
                        ? nextData['senderUID']
                        : 'null';
                    return SizeTransition(
                      axis: Axis.vertical,
                      axisAlignment: -1,
                      sizeFactor: animation,
                      child: MessageBubble(
                        documentData: nowData,
                        pastUID: pastUID,
                        nextUID: nextUID,
                        chatId: chatId,
                        messageId: snap[i]!.id,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 0,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: MessageInput(chatId, title)),
              )
            ],
          ),
        ));
  }
}
