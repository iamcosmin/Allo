import 'package:allo/repositories/repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart' hide CupertinoContextMenu;
import 'package:allo/components/person_picture.dart';
import 'package:flutter/cupertino.dart'
    show
        showCupertinoModalPopup,
        CupertinoActionSheet,
        CupertinoActionSheetAction;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class MessageBubble extends HookWidget {
  final Map documentData;
  final String pastUID;
  final String nextUID;
  final String chatId;
  final String messageId;
  MessageBubble(
      {required this.documentData,
      required this.pastUID,
      required this.nextUID,
      required this.chatId,
      required this.messageId});

  String get name {
    if (documentData.containsKey('name')) {
      return documentData['name'];
    } else if (documentData.containsKey('senderName')) {
      return documentData['senderName'];
    } else {
      return 'No Name';
    }
  }

  String get uid {
    if (documentData.containsKey('uid')) {
      return documentData['username'];
    } else if (documentData.containsKey('senderUID')) {
      return documentData['senderUID'];
    } else {
      return 'No UID';
    }
  }

  String get text {
    if (documentData.containsKey('text')) {
      return documentData['text'];
    } else if (documentData.containsKey('messageTextContent')) {
      return documentData['messageTextContent'];
    } else {
      return 'No Body';
    }
  }

  String get time {
    if (documentData.containsKey('time')) {
      var time = DateTime.fromMillisecondsSinceEpoch(
          (documentData['time'] as Timestamp).millisecondsSinceEpoch);
      return DateFormat.Hm().format(time);
    } else {
      return '00:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = useProvider(Repositories.auth);
    if (uid != auth.user.uid) {
      return _ReceiveMessageBubble(
        name: name,
        uid: uid,
        text: text,
        pastUID: pastUID,
        nextUID: nextUID,
        time: time,
      );
    } else {
      return _SentMessageBubble(
        text: text,
        uid: uid,
        pastUID: pastUID,
        nextUID: nextUID,
        messageId: messageId,
        chatId: chatId,
        time: time,
      );
    }
  }
}

class _ReceiveMessageBubble extends HookWidget {
  // If the nextUID == senderUID, we need to keep the name and to reduce
  // the bottom padding, also eliminate the profile picture as we will put it
  // on the last message.
  // If the pastUID == senderUID, we need to eliminate the name and change bubble
  // characteristics
  _ReceiveMessageBubble(
      {required this.name,
      required this.uid,
      required this.text,
      required this.pastUID,
      required this.nextUID,
      required this.time});

  final String uid;
  final String name;
  final String text;
  final String pastUID;
  final String nextUID;
  final String time;
  bool get isSameSenderAsInPast => uid == pastUID;
  bool get isSameSenderAsInFuture => uid == nextUID;

  double get bottomPadding {
    if (uid == nextUID || nextUID == 'null') {
      return 5;
    } else {
      return 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = useProvider(Repositories.auth);
    final colors = useProvider(Repositories.colors);
    final selected = useState(false);
    final regexEmoji = RegExp(
        r'^(\u00a9|\u00ae|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$');
    void change() =>
        selected.value == true ? selected.value = false : selected.value = true;

    return Container(
      padding:
          EdgeInsets.only(bottom: isSameSenderAsInFuture ? 2 : 15, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Profile picture
              if (!isSameSenderAsInFuture) ...[
                FutureBuilder<String>(
                    future: auth.getUserProfilePicture(uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return PersonPicture.profilePicture(
                            radius: 36, profilePicture: snapshot.data);
                      } else {
                        return PersonPicture.initials(
                            color: Colors.indigo,
                            radius: 36,
                            initials: auth.returnNameInitials(name));
                      }
                    }),
              ] else ...[
                Padding(
                  padding: EdgeInsets.only(left: 36),
                )
              ],

              Padding(padding: EdgeInsets.only(left: 9)),
              // Chat bubble
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSameSenderAsInPast) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 15, bottom: 4),
                      child: Text(
                        name,
                        style: TextStyle(
                            fontSize: 11, color: CupertinoColors.inactiveGray),
                      ),
                    ),
                  ],
                  GestureDetector(
                    onTap: () => change(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.messageBubble,
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(isSameSenderAsInPast ? 0 : 20),
                          bottomLeft: Radius.circular(isSameSenderAsInFuture ||
                                  (isSameSenderAsInFuture &&
                                      isSameSenderAsInPast)
                              ? 0
                              : 20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 1.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: Text(
                              text,
                              style: TextStyle(
                                  fontSize:
                                      regexEmoji.hasMatch(text) ? 30 : 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
              padding: const EdgeInsets.only(left: 60),
              height: selected.value || nextUID == 'null' ? 20 : 0,
              child: Row(
                children: [
                  Text(
                    'Primit',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(padding: EdgeInsets.only(left: 5)),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}

class _SentMessageBubble extends HookWidget {
  _SentMessageBubble({
    required this.text,
    required this.uid,
    required this.pastUID,
    required this.nextUID,
    required this.chatId,
    required this.messageId,
    required this.time,
  });
  final String text;
  final String uid;
  final String pastUID;
  final String nextUID;
  final String chatId;
  final String messageId;
  final String time;
  bool get isSameSenderAsInPast => uid == pastUID;
  bool get isSameSenderAsInFuture => uid == nextUID;

  @override
  Widget build(BuildContext context) {
    final chat = useProvider(Repositories.chats);
    final selected = useState(false);
    void change() =>
        selected.value == true ? selected.value = false : selected.value = true;
    final regexEmoji = RegExp(
        r'^(\u00a9|\u00ae|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$');
    return Container(
      padding:
          EdgeInsets.only(bottom: isSameSenderAsInFuture ? 2 : 15, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Chat bubble
              GestureDetector(
                onTap: () => change(),
                onLongPress: () {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await chat.deleteMessage(
                                      messageId: messageId, chatId: chatId);
                                },
                                isDestructiveAction: true,
                                child: Text('Șterge mesajul'),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              isDefaultAction: true,
                              child: Text('Anulează'),
                            ),
                          ));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight:
                            Radius.circular(isSameSenderAsInPast ? 5 : 20),
                        bottomRight: Radius.circular(isSameSenderAsInFuture ||
                                (isSameSenderAsInFuture && isSameSenderAsInPast)
                            ? 5
                            : 20),
                        bottomLeft: Radius.circular(20)),
                  ),
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 1.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 1),
                        child: Text(
                          text,
                          style: TextStyle(
                              fontSize: regexEmoji.hasMatch(text) ? 30 : 17),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
              padding: const EdgeInsets.only(right: 5),
              height: selected.value || nextUID == 'null' ? 20 : 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Trimis',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(padding: EdgeInsets.only(left: 5)),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
