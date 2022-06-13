import 'dart:typed_data';

import 'package:allo/components/show_bottom_sheet.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/chat.dart';
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
            Core.navigation.push(
              route: UploadImage(
                file,
                await file!.readAsBytes(),
                chatId: chatId,
                chatName: chatName,
                chatType: getStringFromChatType(chatType),
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
          Core.navigation.push(
            route: UploadImage(
              file,
              await file!.readAsBytes(),
              chatId: chatId,
              chatName: chatName,
              chatType: getStringFromChatType(chatType),
              progress: uploadProgressValue,
            ),
          );
        },
      )
    ],
  );
}

/// [ModifierType] is used to define if a Modifier is for replying to a message
/// or for editing a message.
enum ModifierType {
  reply,
  @Deprecated(
    'DO NOT USE THIS VALUE, THIS IS NOT IMPLEMENTED IN LOGIC/CHAT.DART.',
  )
  edit
}

/// [ModifierAction] is used to get suplimentary metadata, such as
/// if the Modifier is for editing some message, or for replying to a message.
/// [ModifierAction] will be modified if there will be new scenarios.
class ModifierAction {
  ModifierAction({required this.type, this.replyMessageId, this.editMessageId})
// Translation: If it is a reply modifier, assert that the replyMessageId is not null, else if it is a edit modifier,
// assert that editMessageId is not null, else, trigger an exception.
      : assert(
          type == ModifierType.reply
              ? replyMessageId != null
              : type == ModifierType.edit
                  ? editMessageId != null
                  : false,
          'Please provide a proper messageId for your provided type.',
        );
  final ModifierType type;
  String? replyMessageId;
  String? editMessageId;
}

class InputModifier {
  /// [InputModifier].
  ///
  /// This is the most complicated piece of code I've created. Ever.
  /// Though, it is mostly simple to use.
  const InputModifier({
    required this.title,
    required this.body,
    required this.icon,
    required this.action,
  });
  final String title;
  final String body;
  final IconData icon;
  final ModifierAction action;
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
    final locales = S.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.all(5),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: theme.secondaryContainer,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSize(
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 450),
            child: modifier.value == null
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 0,
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 10),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Icon(modifier.value?.icon),
                        const Padding(padding: EdgeInsets.only(left: 15)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                modifier.value?.title ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                modifier.value?.body.replaceAll('\n', ' ') ??
                                    '',
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                        if (modifier.value != null) ...[
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  modifier.value = null;
                                },
                              ),
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 25,
                color: theme.onSecondaryContainer,
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
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 120,
                  minHeight: 20,
                ),
                width: MediaQuery.of(context).size.width - 110,
                child: TextFormField(
                  cursorColor: Theme.of(context).colorScheme.outline,
                  minLines: 1,
                  focusNode: node,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: locales.message,
                    hintStyle: TextStyle(color: theme.onSecondaryContainer),
                  ),
                  onChanged: (value) =>
                      value == '' ? empty.value = true : empty.value = false,
                  controller: messageController,
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
                    onPressed: empty.value
                        ? null
                        : () {
                            empty.value = true;
                            Core.chat(chatId).messages.sendTextMessage(
                                  chatType: getStringFromChatType(chatType),
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
          await Core.chat(chatId).messages.sendImageMessage(
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
