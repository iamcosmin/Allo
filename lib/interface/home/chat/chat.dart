import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:allo/components/progress_rings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:allo/components/chatnavigationbar.dart';
import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/message_bubble.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: must_be_immutable
class Chat extends HookWidget {
  final String _chatReference = 'DFqPHH2R4E5j0tM55fIm';
  String? title;
  Chat({this.title});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      FirebaseMessaging.instance.subscribeToTopic('allo_chat_messages');
    }, const []);
    return CupertinoPageScaffold(
        navigationBar: ChatNavigationBar(
          middle: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Allo'),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'conversație principală',
                  style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey2,
                      fontWeight: FontWeight.normal),
                ),
              )
            ],
          ),
          trailing: PersonPicture.initials(
            radius: 46,
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
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(_chatReference)
                .collection('messages')
                .orderBy('time', descending: true)
                .limit(15)
                .snapshots(),
            builder: (ctx, AsyncSnapshot<QuerySnapshot> snap) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                switchInCurve: Curves.easeInCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: snap.hasData
                    ? MessageList(chatReference: _chatReference, snap: snap)
                    : SafeArea(
                        child: Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            child: ProgressRing(),
                          ),
                        ),
                      ),
              );
            },
          ),
        ));
  }
}

class MessageList extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snap;
  final String chatReference;
  const MessageList({
    required this.snap,
    required this.chatReference,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView.builder(
          itemCount: snap.data!.docs.length,
          reverse: true,
          itemBuilder: (BuildContext ctx, int length) {
            return MessageBubble(snap.data!.docs[length].data() as Map);
          },
        ),
      ),
      MessageInput(chatReference),
    ]);
  }
}
