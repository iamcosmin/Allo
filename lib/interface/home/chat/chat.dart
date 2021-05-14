import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:allo/components/chatnavigationbar.dart';
import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/message_bubble.dart';
import 'package:allo/components/person_picture.dart';
import 'package:allo/components/progress.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: must_be_immutable
class Chat extends HookWidget {
  String _chatReference = 'DFqPHH2R4E5j0tM55fIm';
  String? title;
  Chat({this.title});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: CupertinoColors.darkBackgroundGray));
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
          child: ListView(
            reverse: true,
            children: [
              MessageInput(_chatReference),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(_chatReference)
                    .collection('messages')
                    .orderBy('time', descending: true)
                    .limit(15)
                    .snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot> snap) {
                  if (snap.hasData) {
                    return Container(
                      height: MediaQuery.of(context).size.height - 140,
                      child: ListView.builder(
                        itemCount: snap.data!.docs.length,
                        reverse: true,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        itemBuilder: (BuildContext ctx, int length) {
                          return MessageBubble(
                              snap.data!.docs[length]['senderUsername'],
                              snap.data!.docs[length]['messageTextContent']);
                        },
                      ),
                    );
                  } else {
                    return SafeArea(
                      child: Container(
                        height: 50,
                        width: 50,
                        alignment: Alignment.center,
                        child: ProgressRing(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ));
  }
}
