import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provides input actions for the Chat object.
// ignore: must_be_immutable
class MessageInput extends HookWidget {
  final String chatId;
  final String chatName;
  MessageInput(this.chatId, this.chatName);

  @override
  Widget build(BuildContext context) {
    final alerts = useProvider(Repositories.alerts);
    final chats = useProvider(Repositories.chats);
    final colors = useProvider(Repositories.colors);
    final empty = useState(true);
    final _messageController = useTextEditingController();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: colors.messageInput),
          child: Row(
            children: [
              IconButton(
                alignment: Alignment.center,
                iconSize: 25,
                icon: empty.value
                    ? Icon(FluentIcons.attach_16_regular)
                    : Icon(FluentIcons.search_16_regular),
                onPressed: () => alerts.noSuchMethodError(context),
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 120,
                  minHeight: 20,
                  minWidth: MediaQuery.of(context).size.width - 110,
                  maxWidth: MediaQuery.of(context).size.width - 110,
                ),
                child: TextFormField(
                  minLines: 1,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Mesaj',
                  ),
                  onChanged: (value) =>
                      value == '' ? empty.value = true : empty.value = false,
                  controller: _messageController,
                ),
              ),
              IconButton(
                alignment: Alignment.center,
                iconSize: 25,
                icon: Icon(FluentIcons.send_16_filled),
                onPressed: empty.value
                    ? null
                    : () {
                        empty.value = true;
                        chats.send.sendTextMessage(
                            text: _messageController.text,
                            chatId: chatId,
                            context: context,
                            chatName: chatName,
                            controller: _messageController);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
