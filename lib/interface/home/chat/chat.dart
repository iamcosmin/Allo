import 'package:allo/components/appbar.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:allo/components/chats/message_input.dart';
import 'package:allo/components/message_bubble.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class Chat extends HookWidget {
  String title;
  String chatId;
  Chat({required this.title, required this.chatId});
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  @override
  Widget build(BuildContext context) {
    final documentLoad = useState(20);
    final documentList = useState(<DocumentSnapshot>[]);
    final auth = useProvider(Repositories.auth);

    int _indexForKey(String key) {
      assert(key.isNotEmpty);
      return documentList.value.indexWhere((item) => item.id == key);
    }

    useEffect(() {
      if (!kIsWeb) {
        FirebaseMessaging.instance.subscribeToTopic(chatId);
      }
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('time', descending: true)
          .limit(documentLoad.value)
          .snapshots()
          .listen((event) {
        for (var doc in event.docChanges) {
          if (doc.type == DocumentChangeType.added) {
            documentList.value.insert(doc.newIndex, doc.doc);
            if (listKey.currentState != null) {
              listKey.currentState!.insertItem(doc.newIndex);
            }
          } else if (doc.type == DocumentChangeType.removed) {
            documentList.value.removeAt(doc.oldIndex);
            if (listKey.currentState != null) {
              listKey.currentState!.removeItem(
                  doc.oldIndex,
                  (context, animation) => SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.vertical,
                        axisAlignment: -1.0,
                      ));
            }
          } else if (doc.type == DocumentChangeType.modified) {
            documentList.value[doc.oldIndex] = doc.doc;
            print(documentList.value[doc.newIndex].data() as Map);
          }
        }
      });
    }, []);
    return Scaffold(
        appBar: NavBar(
          toolbarHeight: 100,
          leading: Container(
            padding: EdgeInsets.only(left: 10, top: 0),
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(FluentIcons.arrow_left_16_regular),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(left: 20, bottom: 10),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(right: 10),
                  child: Hero(
                    tag: chatId,
                    child: PersonPicture.initials(
                      radius: 37,
                      initials: auth.returnNameInitials(title),
                      color: Colors.blue,
                    ),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: NotificationListener(
                  onNotification: (value) {
                    if (value is ScrollNotification) {
                      final before = value.metrics.extentBefore;
                      final max = value.metrics.maxScrollExtent;

                      if (before == max) {}
                    }
                    return false;
                  },
                  child: AnimatedList(
                    physics: BouncingScrollPhysics(),
                    key: listKey,
                    reverse: true,
                    itemBuilder: (context, i, animation) {
                      final Map pastData, nextData;
                      if (i == 0) {
                        nextData = {'senderUID': 'null'};
                      } else {
                        nextData = documentList.value[i - 1].data() as Map;
                      }
                      if (i == documentList.value.length - 1) {
                        pastData = {'senderUID': 'null'};
                      } else {
                        pastData = documentList.value[i + 1].data() as Map;
                      }
                      // Above, pastData should have been i-1 and nextData i+1.
                      // But, as the list needs to be in reverse order, we need
                      // to consider this workaround.
                      final pastUID = pastData.containsKey('uid')
                          ? pastData['uid']
                          : pastData.containsKey('senderUID')
                              ? pastData['senderUID']
                              : 'null';
                      final nextUID = nextData.containsKey('uid')
                          ? nextData['uid']
                          : nextData.containsKey('senderUID')
                              ? nextData['senderUID']
                              : 'null';
                      final documentData = documentList.value[i].data() as Map;
                      var name = documentData['name'] ??
                          documentData['senderName'] ??
                          'No name';
                      var uid = documentData['uid'] ??
                          documentData['senderUID'] ??
                          'No UID';
                      String text = documentData['text'] ??
                          documentData['messageTextContent'] ??
                          'No text';
                      var msSE = DateTime.fromMillisecondsSinceEpoch(
                          (documentData['time'] as Timestamp)
                              .millisecondsSinceEpoch);
                      bool isRead = documentData['read'] ?? false;
                      var time = DateFormat.Hm().format(msSE);
                      return SizeTransition(
                        axisAlignment: -1.0,
                        sizeFactor: animation,
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                              curve: Curves.easeIn, parent: animation),
                          child: MessageBubble(
                            key: UniqueKey(),
                            isRead: isRead,
                            name: name,
                            text: text,
                            time: time,
                            uid: uid,
                            pastUID: pastUID,
                            nextUID: nextUID,
                            chatId: chatId,
                            messageId: documentList.value[i].id,
                          ),
                        ),
                      );
                    },
                  ),
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
