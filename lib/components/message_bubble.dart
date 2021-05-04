import 'package:allo/components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:allo/components/person_picture.dart';

class MessageBubble extends StatefulWidget {
  final String senderUsername;
  final String messageTextContent;
  MessageBubble(this.senderUsername, this.messageTextContent);

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final BorderRadiusGeometry _messageBubbleBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomRight: Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(padding: EdgeInsets.only(left: 10)),
          PersonPicture.initials(
              radius: 40,
              initials: widget.senderUsername.characters.first,
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
                      color: FluentColors.messageBubble,
                      borderRadius: _messageBubbleBorderRadius,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 5),
                            child: Text(
                              widget.senderUsername,
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Text(
                            widget.messageTextContent,
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
