import 'package:allo/components/chats/bubbles/sent.dart';
import 'package:allo/repositories/chats_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../person_picture.dart';

class ReceiveMessageBubble extends HookWidget {
  // If the nextUID == senderUID, we need to keep the name and to reduce
  // the bottom padding, also eliminate the profile picture as we will put it
  // on the last message.
  // If the pastUID == senderUID, we need to eliminate the name and change bubble
  // characteristics
  ReceiveMessageBubble(
      {required Key key,
      required this.pastUID,
      required this.nextUID,
      required this.chatId,
      required this.chatType,
      required this.data})
      : super(key: key);
  String pastUID;
  String nextUID;
  String chatId;
  String chatType;
  DocumentSnapshot data;

  @override
  Widget build(BuildContext context) {
    final documentData = data.data() as Map;
    var name = documentData['name'] ?? documentData['senderName'] ?? 'No name';
    var uid = documentData['uid'] ?? documentData['senderUID'] ?? 'No UID';
    String text =
        documentData['text'] ?? documentData['messageTextContent'] ?? 'No text';
    var msSE = DateTime.fromMillisecondsSinceEpoch(
        (documentData['time'] as Timestamp).millisecondsSinceEpoch);
    bool isRead = documentData['read'] ?? false;
    var time = DateFormat.Hm().format(msSE);
    var messageId = data.id;
    var type = documentData['type'];

    var isSameSenderAsInPast = uid == pastUID;
    var isSameSenderAsInFuture = uid == nextUID;
    final auth = useProvider(Repositories.auth);
    final colors = useProvider(Repositories.colors);
    final selected = useState(false);
    final chats = useProvider(Repositories.chats);
    final bubbleRadius = BorderRadius.only(
      topLeft: Radius.circular(isSameSenderAsInPast ? 0 : 20),
      bottomLeft: Radius.circular(isSameSenderAsInFuture ||
              (isSameSenderAsInFuture && isSameSenderAsInPast)
          ? 0
          : 20),
      topRight: Radius.circular(20),
      bottomRight: Radius.circular(20),
    );
    final navigation = useProvider(Repositories.navigation);
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Profile picture
              if (chatType == ChatType.group) ...[
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
              ] else
                ...[],

              Padding(padding: EdgeInsets.only(left: 9)),
              // Chat bubble
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSameSenderAsInPast && chatType == ChatType.group) ...[
                    Padding(
                      padding: EdgeInsets.only(left: 15, bottom: 4),
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                  if (type == MessageTypes.TEXT) ...[
                    GestureDetector(
                      onTap: () => change(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.messageBubble,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(isSameSenderAsInPast ? 0 : 20),
                            bottomLeft: Radius.circular(
                                isSameSenderAsInFuture ||
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
                  ] else if (type == MessageTypes.IMAGE) ...[
                    GestureDetector(
                      onTap: () => navigation.push(
                        context,
                        ImageView(
                          documentData['link'],
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: bubbleRadius,
                        ),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width / 1.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: bubbleRadius,
                              child: Hero(
                                tag: documentData['link'],
                                child: CachedNetworkImage(
                                  imageUrl: documentData['link'],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              )
            ],
          ),
          AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
              padding:
                  EdgeInsets.only(left: chatType == ChatType.private ? 20 : 60),
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
