import 'package:allo/repositories/repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:allo/components/person_picture.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class MessageBubble extends HookWidget {
  final String name;
  final String uid;
  final bool isRead;
  final String text;
  final String time;
  final String pastUID;
  final String nextUID;
  final String chatId;
  final String messageId;
  MessageBubble({
    required Key key,
    required this.name,
    required this.uid,
    required this.isRead,
    required this.text,
    required this.time,
    required this.pastUID,
    required this.nextUID,
    required this.chatId,
    required this.messageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = useProvider(Repositories.auth);
    if (uid != auth.user.uid) {
      return _ReceiveMessageBubble(
        key: UniqueKey(),
        name: name,
        uid: uid,
        text: text,
        pastUID: pastUID,
        nextUID: nextUID,
        time: time,
        messageId: messageId,
        chatId: chatId,
        isRead: isRead,
      );
    } else {
      return _SentMessageBubble(
        key: UniqueKey(),
        isRead: isRead,
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
      {required Key key,
      required this.name,
      required this.uid,
      required this.text,
      required this.pastUID,
      required this.nextUID,
      required this.time,
      required this.isRead,
      required this.chatId,
      required this.messageId})
      : super(key: key);

  final String uid;
  final String name;
  final String text;
  final String pastUID;
  final String nextUID;
  final String time;
  final bool isRead;
  final String chatId;
  final String messageId;
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
    final chats = useProvider(Repositories.chats);
    final regexEmoji = RegExp(
        r'^(\u00a9|\u00ae|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$');
    void change() =>
        selected.value == true ? selected.value = false : selected.value = true;
    useEffect(() {
      if (!isRead) {
        chats.markAsRead(chatId: chatId, messageId: messageId);
      }
    });

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
                      padding: EdgeInsets.only(left: 15, bottom: 4),
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
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
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: Text(
                              text,
                              style: TextStyle(
                                  fontSize:
                                      regexEmoji.hasMatch(text) ? 30 : 16),
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
              padding: EdgeInsets.only(left: 60),
              height: selected.value || nextUID == 'null' ? 20 : 0,
              child: Row(
                children: [
                  Text(
                    'Primit',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(padding: EdgeInsets.only(left: 3)),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
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
  _SentMessageBubble(
      {required Key key,
      required this.text,
      required this.uid,
      required this.pastUID,
      required this.nextUID,
      required this.chatId,
      required this.messageId,
      required this.time,
      required this.isRead})
      : super(key: key);
  final String text;
  final String uid;
  final String pastUID;
  final String nextUID;
  final String chatId;
  final String messageId;
  final String time;
  final bool isRead;
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
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Material(
                          child: Container(
                            height: 200,
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Container(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        FluentIcons.dismiss_circle_20_filled,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              Future.delayed(
                                                  Duration(seconds: 1),
                                                  () => chat.deleteMessage(
                                                      messageId: messageId,
                                                      chatId: chatId));
                                            },
                                            child: ClipOval(
                                              child: Container(
                                                height: 60,
                                                width: 60,
                                                alignment: Alignment.center,
                                                color: Colors.red,
                                                child: Icon(
                                                  FluentIcons.delete_16_regular,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: Text(
                                                'Șterge mesajul',
                                                style: TextStyle(fontSize: 16),
                                              )),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
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
                        padding: EdgeInsets.only(left: 5, right: 1),
                        child: Text(
                          text,
                          style: TextStyle(
                              fontSize: regexEmoji.hasMatch(text) ? 30 : 16),
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
              padding: EdgeInsets.only(right: 5),
              height: selected.value || (isRead == true && nextUID == 'null')
                  ? 20
                  : 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isRead == true ? 'Citit' : 'Trimis',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(padding: EdgeInsets.only(left: 3)),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
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
