import 'package:allo/repositories/repositories.dart';
import 'package:flutter/cupertino.dart';
import 'package:allo/components/person_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MessageBubble extends HookWidget {
  final String senderUsername;
  final String messageTextContent;
  MessageBubble(this.senderUsername, this.messageTextContent);

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
    final shared = useProvider(sharedUtilityProvider);
    if (shared.returnResult('username') != senderUsername) {
      return Align(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(padding: EdgeInsets.only(left: 10)),
              PersonPicture.initials(
                  radius: 40,
                  initials: senderUsername.characters.first,
                  gradient: LinearGradient(colors: [
                    Color(0xFFcc2b5e),
                    Color(0xFF753a88),
                  ])),
              Container(
                width: 270,
                padding: EdgeInsets.only(top: 15, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: colors.messageBubble,
                          borderRadius: _receiveMessageBubbleBorderRadius,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 5, left: 5),
                                child: Text(
                                  senderUsername,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Text(
                                messageTextContent,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ));
    } else {
      return Align(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(padding: EdgeInsets.only(right: 10)),
            Container(
              width: 270,
              padding: EdgeInsets.only(top: 15, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).primaryColor,
                        borderRadius: _sendMessageBubbleBorderRadius,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              messageTextContent,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
