import 'dart:typed_data';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Provides input actions for the Chat object.
// ignore: must_be_immutable
class MessageInput extends HookWidget {
  final String chatId;
  final String chatName;
  final String chatType;
  MessageInput(this.chatId, this.chatName, this.chatType);

  void image(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return AttachWidget(
            chatId: chatId,
            chatName: chatName,
            chatType: chatType,
          );
        });
  }

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
                  onPressed: () => image(context)),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 120,
                  minHeight: 20,
                  minWidth: MediaQuery.of(context).size.width - 110,
                  maxWidth: MediaQuery.of(context).size.width - 110,
                ),
                child: TextFormField(
                  minLines: 1,
                  autofocus: false,
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
                            chatType: chatType,
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

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus;
}

class AttachWidget extends HookWidget {
  AttachWidget(
      {required this.chatName, required this.chatId, required this.chatType});
  final String chatName;
  final String chatId;
  final String chatType;

  @override
  Widget build(BuildContext context) {
    final file = useState<XFile?>(null);
    final progress = useState<double>(0);
    final chats = useProvider(Repositories.chats);
    final navigation = useProvider(Repositories.navigation);
    return Padding(
      padding: EdgeInsets.all(15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Theme.of(context).cardColor,
          height: 200,
          child: Padding(
            padding: EdgeInsets.all(15),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            file.value = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            Navigator.of(context).pop();
                            await navigation.push(
                              context,
                              UploadImage(
                                file.value,
                                await file.value!.readAsBytes(),
                                chatId: chatId,
                                chatName: chatName,
                                chatType: chatType,
                              ),
                            );
                          },
                          child: ClipOval(
                            child: Container(
                              height: 60,
                              width: 60,
                              alignment: Alignment.center,
                              color: Colors.amber,
                              child: Icon(
                                FluentIcons.image_16_regular,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Galerie',
                              style: TextStyle(fontSize: 16),
                            )),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(left: 40)),
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            file.value = await ImagePicker()
                                .pickImage(source: ImageSource.camera)
                                .catchError((e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Nicio cameră disponibilă.'),
                                  action: SnackBarAction(
                                      label: 'OK',
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                      }),
                                ),
                              );
                            });
                          },
                          child: ClipOval(
                            child: Container(
                              height: 60,
                              width: 60,
                              alignment: Alignment.center,
                              color: Colors.blue,
                              child: Icon(
                                FluentIcons.camera_16_regular,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Cameră',
                              style: TextStyle(fontSize: 16),
                            )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UploadImage extends HookWidget {
  UploadImage(this.imageFile, this.imageFileBytes,
      {required this.chatId, required this.chatName, required this.chatType});
  final XFile? imageFile;
  final Uint8List imageFileBytes;
  final String chatName;
  final String chatId;
  final String chatType;
  @override
  Widget build(BuildContext context) {
    final chats = useProvider(Repositories.chats);
    final progress = useState<double>(0);
    final selected = useState(false);
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            selected.value = true;
            await chats.send.sendImageMessage(
                chatName: chatName,
                imageFile: imageFile!,
                chatId: chatId,
                description: 'Imagine',
                progress: progress,
                context: context,
                chatType: chatType);
          },
          child: selected.value == false
              ? Icon(FluentIcons.checkmark_20_regular)
              : CircularProgressIndicator(
                  value: progress.value,
                  color: Colors.white,
                )),
      body: Center(
        child: Image.memory(imageFileBytes),
      ),
    );
  }
}
