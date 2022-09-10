import 'dart:typed_data';

import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/types.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

void _attachMenu({
  required BuildContext context,
  required ValueNotifier<double> uploadProgressValue,
  required ChatType chatType,
  required String chatName,
  required String chatId,
  required ColorScheme colorScheme,
  required WidgetRef ref,
}) {
  final locales = S.of(context);
  XFile? file;
  showMagicBottomSheet(
    colorScheme: colorScheme,
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
            Navigation.forward(
              UploadImage(
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
                  },
                ),
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
          Navigation.forward(
            UploadImage(
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

abstract class InputModifier {
  const InputModifier({
    required this.title,
    required this.body,
    required this.icon,
    this.id,
  });
  final String title;
  final String body;
  final IconData icon;
  final String? id;
}

class ReplyInputModifier extends InputModifier {
  const ReplyInputModifier({
    required String name,
    required String message,
    required super.id,
  }) : super(
          title: name,
          body: message,
          icon: Icons.reply,
        );
}

/// Not ready for production use, abstract.
abstract class EditInputModifier extends InputModifier {
  const EditInputModifier({
    required super.title,
    required super.body,
    required super.id,
    super.icon = Icons.edit,
  });
}

/// Provides input actions for the Chat object.
class MessageInput extends HookConsumerWidget {
  final String chatId;
  final String chatName;
  final ChatType chatType;
  final ColorScheme theme;
  final ValueNotifier<InputModifier?> modifier;
  const MessageInput({
    required this.chatId,
    required this.chatName,
    required this.chatType,
    required this.theme,
    required this.modifier,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empty = useState(true);
    final messageController = useTextEditingController();
    final node = useFocusNode(descendantsAreFocusable: false);
    final progress = useState<double>(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.all(5),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: theme.secondaryContainer,
      ),
      child: Column(
        children: [
          AnimatedSize(
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 250),
            child: modifier.value == null
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 0,
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.only(left: 10, right: 5),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Icon(
                          modifier.value?.icon,
                          color: theme.onSecondaryContainer,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 15)),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                modifier.value?.title ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.onSecondaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                modifier.value?.body.replaceAll('\n', ' ') ??
                                    '',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.onSecondaryContainer,
                                ),
                              )
                            ],
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 15)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          padding: EdgeInsets.zero,
                          color: theme.onSecondaryContainer,
                          onPressed: () {
                            modifier.value = null;
                          },
                        )
                      ],
                    ),
                  ),
          ),
          Row(
            children: [
              IconButton(
                iconSize: 25,
                color: theme.onSecondaryContainer,
                disabledColor: theme.onSecondaryContainer.withOpacity(0.5),
                icon: empty.value
                    ? const Icon(Icons.attach_file_outlined)
                    : const Icon(Icons.search_outlined),
                onPressed: empty.value == false || modifier.value != null
                    ? null
                    : () => _attachMenu(
                          chatId: chatId,
                          chatName: chatName,
                          chatType: chatType,
                          context: context,
                          uploadProgressValue: progress,
                          colorScheme: theme,
                          ref: ref,
                        ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 120,
                    minHeight: 45,
                  ),
                  child: TextFormField(
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    style: TextStyle(color: theme.onSecondaryContainer),
                    focusNode: node,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: context.locale.message,
                      hintStyle: TextStyle(
                        color: theme.onSecondaryContainer.withOpacity(0.7),
                      ),
                    ),
                    onChanged: (value) =>
                        value == '' ? empty.value = true : empty.value = false,
                    controller: messageController,
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: AnimatedCircularProgressIndicator(
                      strokeWidth: 3,
                      value: progress.value,
                      color: theme.primary,
                    ),
                  ),
                  IconButton(
                    iconSize: progress.value == 0 ? 23 : 17,
                    icon: const Icon(Icons.send_rounded),
                    color: theme.onSecondaryContainer,
                    disabledColor: theme.onSecondaryContainer.withOpacity(0.5),
                    onPressed: empty.value
                        ? null
                        : () {
                            empty.value = true;
                            Core.chats.chat(chatId).messages.sendTextMessage(
                                  chatType: chatType,
                                  text: messageController.text,
                                  chatName: chatName,
                                  controller: messageController,
                                  modifier: modifier,
                                );
                          },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UploadImage extends HookWidget {
  const UploadImage(
    this.imageFile,
    this.imageFileBytes, {
    required this.chatId,
    required this.chatName,
    required this.chatType,
    required this.progress,
    super.key,
  });
  final XFile? imageFile;
  final Uint8List imageFileBytes;
  final String chatName;
  final String chatId;
  final ChatType chatType;
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
          Navigation.backward();
          await Core.chats.chat(chatId).messages.sendImageMessage(
                chatName: chatName,
                imageFile: imageFile!,
                description: 'Imagine',
                progress: progress,
                context: context,
                chatType: chatType,
              );
        },
        child: const Icon(Icons.check_rounded),
      ),
      body: Center(
        child: Image.memory(imageFileBytes),
      ),
    );
  }
}
