import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart' hide CupertinoContextMenu;
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MessageBubble extends HookWidget {
  final Map documentData;
  final String pastUID;
  final String nextUID;
  MessageBubble(
      {required this.documentData,
      required this.pastUID,
      required this.nextUID});

  String get senderUID {
    if (documentData.containsKey('senderUID')) {
      return documentData['senderUID'];
    } else if (documentData.containsKey('senderUsername')) {
      return documentData['senderUsername'];
    } else {
      return 'noid';
    }
  }

  String get senderName {
    if (documentData.containsKey('senderName')) {
      return documentData['senderName'];
    } else {
      return senderUID;
    }
  }

  String get messageTextContent {
    if (documentData.containsKey('messageTextContent')) {
      return documentData['messageTextContent'];
    } else {
      return 'Acest utilizator nu a scris nimic in mesaj. Acest lucru nu este posibil. Contacteaza administratorul.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser?.uid != senderUID) {
      return _ReceiveMessageBubble(
        senderName: senderName,
        senderUID: senderUID,
        messageTextContent: messageTextContent,
        pastUID: pastUID,
        nextUID: nextUID,
      );
    } else {
      return _SentMessageBubble(
        messageTextContent: messageTextContent,
        senderUID: senderUID,
        pastUID: pastUID,
        nextUID: nextUID,
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
      {required this.senderName,
      required this.senderUID,
      required this.messageTextContent,
      required this.pastUID,
      required this.nextUID});

  final String senderUID;
  final String senderName;
  final String messageTextContent;
  final String pastUID;
  final String nextUID;
  bool get isSameSenderAsInPast => senderUID == pastUID;
  bool get isSameSenderAsInFuture => senderUID == nextUID;

  double get bottomPadding {
    if (senderUID == nextUID) {
      return 5;
    } else {
      return 15;
    }
  }

  final BorderRadiusGeometry _borderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomRight: Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    final auth = useProvider(Repositories.auth);
    final colors = useProvider(Repositories.colors);
    return Container(
      padding:
          EdgeInsets.only(bottom: isSameSenderAsInFuture ? 2 : 15, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Profile picture
          if (!isSameSenderAsInFuture) ...[
            FutureBuilder<String>(
                future: auth.getUserProfilePicture(senderUID),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return PersonPicture.profilePicture(
                        radius: 36, profilePicture: snapshot.data);
                  } else {
                    return PersonPicture.initials(
                        color: CupertinoColors.systemIndigo,
                        radius: 36,
                        initials: auth.returnNameInitials(senderName));
                  }
                }),
          ] else ...[
            Padding(
              padding: EdgeInsets.only(left: 36),
            )
          ],

          Padding(padding: EdgeInsets.only(left: 9)),
          // Chat bubble
          Container(
            decoration: BoxDecoration(
              color: colors.messageBubble,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSameSenderAsInPast ? 0 : 20),
                bottomLeft: Radius.circular(isSameSenderAsInFuture ||
                        (isSameSenderAsInFuture && isSameSenderAsInPast)
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
                if (!isSameSenderAsInPast) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 3, bottom: 4),
                    child: Text(
                      senderName,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Text(messageTextContent),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SentMessageBubble extends HookWidget {
  _SentMessageBubble({
    required this.messageTextContent,
    required this.senderUID,
    required this.pastUID,
    required this.nextUID,
  });
  final String messageTextContent;
  final String senderUID;
  final String pastUID;
  final String nextUID;
  bool get isSameSenderAsInPast => senderUID == pastUID;
  bool get isSameSenderAsInFuture => senderUID == nextUID;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: isSameSenderAsInFuture ? 2 : 15, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Chat bubble
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.activeOrange,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(isSameSenderAsInPast ? 0 : 20),
                  bottomRight: Radius.circular(isSameSenderAsInFuture ||
                          (isSameSenderAsInFuture && isSameSenderAsInPast)
                      ? 0
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
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Text(messageTextContent),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
