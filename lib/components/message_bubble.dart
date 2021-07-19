import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart' hide CupertinoContextMenu;
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MessageBubble extends HookWidget {
  final Map documentData;
  MessageBubble(this.documentData);

  String senderUID() {
    if (documentData.containsKey('senderUID')) {
      return documentData['senderUID'];
    } else if (documentData.containsKey('senderUsername')) {
      return documentData['senderUsername'];
    } else {
      return 'Niciun nume';
    }
  }

  String senderName() {
    if (documentData.containsKey('senderName')) {
      return documentData['senderName'];
    } else {
      return senderUID();
    }
  }

  String messageTextContent() {
    if (documentData.containsKey('messageTextContent')) {
      return documentData['messageTextContent'];
    } else {
      return 'Acest utilizator nu a scris nimic in mesaj. Acest lucru nu este posibil. Contacteaza administratorul.';
    }
  }

  final BorderRadiusGeometry _receiveMessageBubbleBorderRadius =
      BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20));
  final _sendMessageBubbleBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    final colors = useProvider(fluentColors);
    useEffect(() {}, const []);
    final experimentalOptions = useProvider(experimentalMessageOptions);
    final auth = useProvider(Repositories.auth);

    if (FirebaseAuth.instance.currentUser?.uid != senderUID()) {
      return Container(
        padding: const EdgeInsets.only(bottom: 15, left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Profile picture
            FutureBuilder<String>(
                future: auth.getUserProfilePicture(senderUID()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return PersonPicture.profilePicture(
                        radius: 40, profilePicture: snapshot.data);
                  } else {
                    return PersonPicture.initials(
                        color: CupertinoColors.systemIndigo,
                        radius: 40,
                        initials: auth.returnNameInitials(senderName()));
                  }
                }),
            Padding(padding: EdgeInsets.only(left: 10)),
            // Chat bubble
            Container(
              decoration: BoxDecoration(
                  color: colors.messageBubble,
                  borderRadius: _receiveMessageBubbleBorderRadius),
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3, bottom: 4),
                    child: Text(
                      senderName(),
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(messageTextContent()),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(bottom: 15, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Chat bubble
            Container(
              decoration: BoxDecoration(
                  color: CupertinoColors.activeOrange,
                  borderRadius: _sendMessageBubbleBorderRadius),
              padding: EdgeInsets.all(9),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(messageTextContent()),
                ],
              ),
            )
          ],
        ),
      );
    }
  }
}
