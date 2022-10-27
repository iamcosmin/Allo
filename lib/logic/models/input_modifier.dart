import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: library_private_types_in_public_api
AutoDisposeStateNotifierProvider<_InputModifierManager, InputModifier?>
    inputModifierOf(String chatId) {
  return StateNotifierProvider.autoDispose<_InputModifierManager,
      InputModifier?>(
    (ref) {
      return _InputModifierManager(chatId);
    },
  );
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

/// [ModifierAction] is used to get suplimentary metadata, such as
/// if the Modifier is for editing some message, or for replying to a message.
/// [ModifierAction] will be modified if there will be new scenarios.
class ModifierAction {
  ModifierAction({
    required this.type,
    required this.messageId,
  });

  final ModifierType type;
  final String messageId;
}

/// [ModifierType] is used to define if a Modifier is for replying to a message
/// or for editing a message.
enum ModifierType {
  reply,
  // edit
}

class _InputModifierManager extends StateNotifier<InputModifier?> {
  _InputModifierManager(this.chatId) : super(null);

  final String chatId;
  void update(InputModifier modifier) {
    state = modifier;
  }

  void revoke() {
    state = null;
  }
}
