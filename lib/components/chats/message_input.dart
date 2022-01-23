import 'dart:typed_data';

import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

void _attachMenu({
  required BuildContext context,
  required ValueNotifier<double> uploadProgressValue,
  required String chatType,
  required String chatName,
  required String chatId,
}) {
  final locales = S.of(context);
  XFile? file;
  showMagicBottomSheet(
    context: context,
    title: locales.attach,
    children: [
      ListTile(
        leading: const Icon(Icons.camera_alt_outlined),
        title: Text(locales.camera),
        onTap: () async {
          try {
            Navigator.of(context).pop();
            file = await ImagePicker().pickImage(source: ImageSource.camera);
            await Core.navigation.push(
              context: context,
              route: UploadImage(
                file,
                await file!.readAsBytes(),
                chatId: chatId,
                chatName: chatName,
                chatType: chatType,
                progress: uploadProgressValue,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(locales.noCameraAvailable),
                action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }),
              ),
            );
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.image_outlined),
        title: Text(locales.gallery),
        onTap: () async {
          Navigator.of(context).pop();
          file = await ImagePicker().pickImage(source: ImageSource.gallery);
          await Core.navigation.push(
            context: context,
            route: UploadImage(
              file,
              await file!.readAsBytes(),
              chatId: chatId,
              chatName: chatName,
              chatType: chatType,
              progress: uploadProgressValue,
            ),
          );
        },
      )
    ],
  );
}

/// Provides input actions for the Chat object.
// ignore: must_be_immutable
class MessageInput extends HookConsumerWidget {
  final String chatId;
  final String chatName;
  final String chatType;
  final Color color;
  const MessageInput({
    required this.chatId,
    required this.chatName,
    required this.chatType,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(colorsProvider);
    final empty = useState(true);
    final _messageController = useTextEditingController();
    final _node = useFocusNode(descendantsAreFocusable: false);
    final progress = useState<double>(0);
    final locales = S.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colors.messageInput),
          child: Row(
            children: [
              IconButton(
                alignment: Alignment.center,
                iconSize: 25,
                icon: empty.value
                    ? const Icon(Icons.attach_file_outlined)
                    : const Icon(Icons.search_outlined),
                onPressed: empty.value == false
                    ? null
                    : () => _attachMenu(
                          chatId: chatId,
                          chatName: chatName,
                          chatType: chatType,
                          context: context,
                          uploadProgressValue: progress,
                        ),
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
                  autofocus: false,
                  focusNode: _node,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: locales.message,
                  ),
                  onChanged: (value) =>
                      value == '' ? empty.value = true : empty.value = false,
                  controller: _messageController,
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      value: progress.value,
                      color: color,
                    ),
                  ),
                  IconButton(
                    iconSize: progress.value == 0 ? 23 : 17,
                    icon: const Icon(Icons.send_rounded),
                    onPressed: empty.value
                        ? null
                        : () {
                            empty.value = true;
                            Core.chat(chatId).messages.sendTextMessage(
                                chatType: chatType,
                                text: _messageController.text,
                                context: context,
                                chatName: chatName,
                                controller: _messageController);
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadImage extends HookWidget {
  const UploadImage(this.imageFile, this.imageFileBytes,
      {required this.chatId,
      required this.chatName,
      required this.chatType,
      required this.progress,
      Key? key})
      : super(key: key);
  final XFile? imageFile;
  final Uint8List imageFileBytes;
  final String chatName;
  final String chatId;
  final String chatType;
  final ValueNotifier<double> progress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pop(context);
          progress.value = 0.1;
          await Core.chat(chatId).messages.sendImageMessage(
              chatName: chatName,
              imageFile: imageFile!,
              description: 'Imagine',
              progress: progress,
              context: context,
              chatType: chatType);
        },
        child: const Icon(Icons.check_rounded),
      ),
      body: Center(
        child: Image.memory(imageFileBytes),
      ),
    );
  }
}
