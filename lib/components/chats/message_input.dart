import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provides input actions for the Chat object.
// ignore: must_be_immutable
class MessageInput extends HookWidget {
  late String _messageTextContent;
  final String _chatReference;
  final String senderChatName;
  final TextEditingController _messageController = TextEditingController();
  MessageInput(this._chatReference, this.senderChatName);

  @override
  Widget build(BuildContext context) {
    final alerts = useProvider(Repositories.alerts);
    final chats = useProvider(Repositories.chats);
    final colors = useProvider(Repositories.colors);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Color(0xFF000000),
        child: Container(
          padding: const EdgeInsets.only(bottom: 2, left: 5, right: 5, top: 2),
          color: colors.messageInput,
          child: Container(
            color: Colors.grey.shade900,
            child: Row(
              children: [
                IconButton(
                  alignment: Alignment.center,
                  iconSize: 25,
                  color: Colors.grey,
                  icon: Icon(Icons.attach_file),
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
                  child: TextFormField(
                    scrollPadding: MediaQuery.of(context).viewInsets,
                    minLines: 1,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Mesaj',
                    ),
                    controller: _messageController,
                    onChanged: (value) => _messageTextContent = value,
                  ),
                ),
                IconButton(
                  alignment: Alignment.center,
                  iconSize: 27.5,
                  icon: Icon(Icons.send),
                  onPressed: () => chats.sendMessage(
                      _messageTextContent,
                      null,
                      MessageType.TEXT_ONLY,
                      _chatReference,
                      senderChatName,
                      _messageController),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
