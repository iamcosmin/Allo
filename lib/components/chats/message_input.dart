import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provides input actions for the Chat object.
// ignore: must_be_immutable
class MessageInput extends HookWidget {
  final String chatId;
  final String chatName;
  final TextEditingController _messageController = TextEditingController();
  MessageInput(this.chatId, this.chatName);

  @override
  Widget build(BuildContext context) {
    final alerts = useProvider(Repositories.alerts);
    final chats = useProvider(Repositories.chats);
    final colors = useProvider(Repositories.colors);
    final text = useState('');

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Color(0xFF000000),
        child: Container(
          padding: const EdgeInsets.only(bottom: 2, left: 5, right: 5, top: 2),
          color: colors.messageInput,
          child: Row(
            children: [
              IconButton(
                alignment: Alignment.center,
                iconSize: 25,
                color: CupertinoColors.systemGrey,
                icon: Icon(CupertinoIcons.paperclip),
                onPressed: () => alerts.noSuchMethodError(context),
              ),
              AnimatedContainer(
                duration: Duration(seconds: 2),
                curve: Curves.ease,
                constraints: BoxConstraints(
                  maxHeight: 150,
                  minHeight: 20,
                  minWidth: MediaQuery.of(context).size.width - 110,
                  maxWidth: MediaQuery.of(context).size.width - 110,
                ),
                child: CupertinoTextField(
                  scrollPadding: MediaQuery.of(context).viewInsets,
                  expands: true,
                  maxLines: null,
                  decoration: BoxDecoration(
                      color: colors.nonColors,
                      borderRadius: BorderRadius.circular(20)),
                  placeholder: 'Mesaj',
                  prefix: Padding(
                    padding: EdgeInsets.only(left: 10),
                  ),
                  controller: _messageController,
                  onChanged: (value) => text.value = value,
                ),
              ),
              IconButton(
                alignment: Alignment.center,
                iconSize: 27.5,
                icon: Icon(CupertinoIcons.arrow_up_circle_fill),
                onPressed: () => chats.send.sendTextMessage(
                    text: text.value,
                    chatId: chatId,
                    context: context,
                    chatName: chatName,
                    controller: _messageController),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
