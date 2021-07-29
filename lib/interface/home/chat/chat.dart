import 'package:allo/components/firestore_animated_list/animated_firestore_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:allo/components/progress_rings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:allo/components/chats/chatnavigationbar.dart';
import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/message_bubble.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: must_be_immutable
class Chat extends HookWidget {
  String title;
  String chatId;
  Chat({required this.title, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final documentLoad = useState(20);
    useEffect(() {
      if (!kIsWeb) {
        FirebaseMessaging.instance.subscribeToTopic(chatId);
      }
    }, const []);
    return CupertinoPageScaffold(
        navigationBar: ChatNavigationBar(
          middle: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text(
                  'conversație',
                  style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey2,
                      fontWeight: FontWeight.normal),
                ),
              )
            ],
          ),
          trailing: PersonPicture.initials(
            radius: 40,
            initials: 'A',
            gradient: LinearGradient(
              colors: [
                Color(0xFFcc2b5e),
                Color(0xFF753a88),
              ],
            ),
          ),
        ),
        child: SafeArea(
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
                    return SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0, 0.5), end: Offset(0, 0))
                          .animate(animation),
                      child: SizeTransition(
                        axis: Axis.vertical,
                        axisAlignment: 0,
                        sizeFactor: animation,
                        child: MessageBubble(
                          documentData: nowData,
                          pastUID: pastUID,
                          nextUID: nextUID,
                          chatId: chatId,
                          messageId: snap[i]!.id,
                        ),
                      ),
                    );
                  },
                ),
                // StreamBuilder(
                //   stream: stream,
                //   builder: (ctx, AsyncSnapshot<QuerySnapshot> snap) {
                //     return AnimatedSwitcher(
                //       duration: Duration(milliseconds: 500),
                //       switchInCurve: Curves.easeInCubic,
                //       switchOutCurve: Curves.easeOutCubic,
                //       child: snap.hasData
                //           ? NotificationListener(
                //               onNotification: (value) {
                //                 if (value is ScrollNotification) {
                //                   final before = value.metrics.extentBefore;
                //                   final max = value.metrics.maxScrollExtent;

                //                   if (before == max) {
                //                     documentLoad.value =
                //                         documentLoad.value + 15;
                //                   }
                //                 }
                //                 return false;
                //               },
                //               child: ListView.builder(
                //                 reverse: true,
                //                 controller: scrollController,
                //                 itemCount: snap.data!.docs.length,
                //                 itemBuilder: (BuildContext ctx, int i) {
                //                   final nowData, pastData, nextData;
                //                   nowData = snap.data!.docs[i].data() as Map;
                //                   if (i == 0) {
                //                     nextData = {'senderUID': 'null'};
                //                   } else {
                //                     nextData =
                //                         snap.data!.docs[i - 1].data() as Map;
                //                   }
                //                   if (i == snap.data!.docs.length - 1) {
                //                     pastData = {'senderUID': 'null'};
                //                   } else {
                //                     pastData =
                //                         snap.data!.docs[i + 1].data() as Map;
                //                   }
                //                   // Above, pastData should have been i-1 and nextData i+1.
                //                   // But, as the list needs to be in reverse order, we need
                //                   // to consider this workaround.
                //                   final pastUID =
                //                       pastData.containsKey('senderUID')
                //                           ? pastData['senderUID']
                //                           : 'null';
                //                   final nextUID =
                //                       nextData.containsKey('senderUID')
                //                           ? nextData['senderUID']
                //                           : 'null';
                //                   return MessageBubble(
                //                     documentData: nowData,
                //                     pastUID: pastUID,
                //                     nextUID: nextUID,
                //                   );
                //                 },
                //               ),
                //             )
                //           : SafeArea(
                //               child: Center(
                //                 child: Container(
                //                   height: 50,
                //                   width: 50,
                //                   child: ProgressRing(),
                //                 ),
                //               ),
                //             ),
                //     );
                //   },
                // ),
              ),
              Expanded(
                flex: 0,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: MessageInput(chatId)),
              )
            ],
          ),
        ));
  }
}
